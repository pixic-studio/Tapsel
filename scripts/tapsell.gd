extends Node

## ==============================================================================
## Tapsell Plus Godot 4 Manager (Autoload / Singleton)
## پشتیبانی از: ویدیو جایزه‌ای (Rewarded Video) و بنر استاندارد ۳۲۰x۵۰ (Standard Banner)
## ==============================================================================

# ==========================================
# 🔑 کلیدهای تپسل (Tapsell Credentials)
# کلیدهای خود را از داشبورد تپسل دریافت و در مقادیر زیر قرار دهید:
# ==========================================
const APP_KEY: String = ""              # کلید اپلیکیشن شما در تپسل (App Key)
const REWARDED_ZONE_ID: String = ""     # شناسه زون ویدیوی جایزه‌ای (Rewarded Video Zone ID)
const BANNER_ZONE_ID: String = ""       # شناسه زون بنر ۳۲۰x۵۰ (Banner Zone ID)

# ==========================================
# 📡 سیگنال‌های عمومی (Public Signals)
# ==========================================
signal initialized(network_info: String)
signal init_failed(error_msg: String)

signal rewarded_video_loaded(response_id: String)
signal rewarded_video_failed(error_msg: String)
signal rewarded_video_opened()
signal rewarded_video_closed()
signal rewarded_video_completed() # هنگامی که کاربر ویدیو را تا انتها دیده و باید جایزه بگیرد

signal banner_loaded(response_id: String)
signal banner_failed(error_msg: String)
signal banner_opened()
signal banner_closed()

# ==========================================
# متغیرهای داخلی
# ==========================================
var _plugin = null
var _is_android: bool = false
var _last_rewarded_response_id: String = ""
var _last_banner_response_id: String = ""

func _ready() -> void:
	_is_android = (OS.get_name() == "Android")
	if not _is_android:
		print("[Tapsell] این پلاگین فقط بر روی سیستم‌عامل اندروید اجرا می‌شود.")
		return
	
	_init_plugin()

func _init_plugin() -> void:
	if Engine.has_singleton("TapsellGodot"):
		_plugin = Engine.get_singleton("TapsellGodot")
		_connect_signals()
		
		if APP_KEY.strip_edges() == "":
			push_warning("[Tapsell] هشدار: APP_KEY خالی است! لطفاً کلید تپسل خود را وارد کنید.")
			return
		
		print("[Tapsell] در حال مقداردهی اولیه تپسل با کلید اپلیکیشن...")
		_plugin.initialize(APP_KEY)
	else:
		push_error("[Tapsell] خطا: سینگلتون TapsellGodot پیدا نشد! مطمئن شوید Use Gradle Build در تنظیمات خروجی فعال است.")

func _connect_signals() -> void:
	_plugin.connect("init_success", Callable(self, "_on_init_success"))
	_plugin.connect("init_failed", Callable(self, "_on_init_failed"))
	
	_plugin.connect("rewarded_video_response", Callable(self, "_on_rewarded_response"))
	_plugin.connect("rewarded_video_error", Callable(self, "_on_rewarded_error"))
	_plugin.connect("rewarded_video_opened", Callable(self, "_on_rewarded_opened"))
	_plugin.connect("rewarded_video_closed", Callable(self, "_on_rewarded_closed"))
	_plugin.connect("rewarded_video_rewarded", Callable(self, "_on_rewarded_rewarded"))
	
	_plugin.connect("banner_response", Callable(self, "_on_banner_response"))
	_plugin.connect("banner_error", Callable(self, "_on_banner_error"))
	_plugin.connect("banner_opened", Callable(self, "_on_banner_opened"))
	_plugin.connect("banner_closed", Callable(self, "_on_banner_closed"))

# ==========================================
# 🎮 متدهای کنترلی ویدیوی جایزه‌ای (Rewarded Video)
# ==========================================

## ارسال درخواست برای لود ویدیوی جایزه‌ای
func request_rewarded_video(zone_id: String = "") -> void:
	if not _plugin:
		return
	var target_zone = zone_id if zone_id != "" else REWARDED_ZONE_ID
	if target_zone.strip_edges() == "":
		push_warning("[Tapsell] شناسه زون ویدیو جایزه‌ای وارد نشده است.")
		return
	_plugin.requestRewardedVideo(target_zone)

## نمایش ویدیوی جایزه‌ای لود شده
func show_rewarded_video(response_id: String = "") -> void:
	if not _plugin:
		return
	var target_res_id = response_id if response_id != "" else _last_rewarded_response_id
	_plugin.showRewardedVideo(target_res_id)

# ==========================================
# 📌 متدهای کنترلی بنر استاندارد ۳۲۰x۵۰ (Standard Banner)
# ==========================================

## ارسال درخواست برای لود بنر ۳۲۰x۵۰
func request_banner(zone_id: String = "") -> void:
	if not _plugin:
		return
	var target_zone = zone_id if zone_id != "" else BANNER_ZONE_ID
	if target_zone.strip_edges() == "":
		push_warning("[Tapsell] شناسه زون بنر وارد نشده است.")
		return
	_plugin.requestBanner(target_zone)

## نمایش بنر ۳۲۰x۵۰ در پایین صفحه
func show_banner(response_id: String = "") -> void:
	if not _plugin:
		return
	var target_res_id = response_id if response_id != "" else _last_banner_response_id
	_plugin.showBanner(target_res_id)

## مخفی‌سازی و بستن بنر استاندارد از روی صفحه
func hide_banner() -> void:
	if not _plugin:
		return
	_plugin.destroyBanner()

# ==========================================
# 📥 هندلرهای سیگنال داخلی
# ==========================================

func _on_init_success(info: String) -> void:
	emit_signal("initialized", info)

func _on_init_failed(err: String) -> void:
	emit_signal("init_failed", err)

func _on_rewarded_response(res_id: String) -> void:
	_last_rewarded_response_id = res_id
	emit_signal("rewarded_video_loaded", res_id)

func _on_rewarded_error(err: String) -> void:
	emit_signal("rewarded_video_failed", err)

func _on_rewarded_opened() -> void:
	emit_signal("rewarded_video_opened")

func _on_rewarded_closed() -> void:
	emit_signal("rewarded_video_closed")

func _on_rewarded_rewarded() -> void:
	emit_signal("rewarded_video_completed")

func _on_banner_response(res_id: String) -> void:
	_last_banner_response_id = res_id
	emit_signal("banner_loaded", res_id)

func _on_banner_error(err: String) -> void:
	emit_signal("banner_failed", err)

func _on_banner_opened() -> void:
	emit_signal("banner_opened")

func _on_banner_closed() -> void:
	emit_signal("banner_closed")
