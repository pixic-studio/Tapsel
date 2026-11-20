extends Control

# ==============================================================================
# 🔑 کلیدهای تپسل (Tapsell Credentials)
# کلیدهای اختصاصی خود را از داشبورد تپسل دریافت کرده و در متغیرهای زیر وارد کنید:
# ==============================================================================
const APP_KEY: String = ""              # کلید اپلیکیشن (App Key)
const REWARDED_ZONE_ID: String = ""     # شناسه زون ویدیوی جایزه‌ای
const BANNER_ZONE_ID: String = ""       # شناسه زون بنر ۳۲۰x۵۰

var tapsell_plugin = null
var is_android: bool = false
var rewarded_response_id: String = ""
var banner_response_id: String = ""

@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var log_display: TextEdit = $VBoxContainer/LogDisplay
@onready var btn_rewarded: Button = $VBoxContainer/BtnRewarded
@onready var btn_banner: Button = $VBoxContainer/HBoxBanner/BtnBanner
@onready var btn_hide_banner: Button = $VBoxContainer/HBoxBanner/BtnHideBanner

func _ready() -> void:
	log_message("برنامه آماده به کار است.")
	is_android = (OS.get_name() == "Android")
	
	if not is_android:
		update_status("توجه: تپسل فقط روی خروجی اندروید فعال می‌شود.", Color.ORANGE)
		log_message("هشدار: اجرای غیراندروید شناسایی شد. لطفاً خروجی APK بگیرید.")
		btn_rewarded.disabled = true
		btn_banner.disabled = true
		btn_hide_banner.disabled = true
		return
	
	if APP_KEY.strip_edges() == "":
		update_status("لطفاً کلیدهای تپسل را در ابتدای اسکریپت وارد کنید.", Color.YELLOW)
		log_message("هشدار: متغیر APP_KEY خالی است. برای شروع کلید تپسل خود را وارد کنید.")
		return
	
	init_tapsell_plugin()

func init_tapsell_plugin() -> void:
	if Engine.has_singleton("TapsellGodot"):
		tapsell_plugin = Engine.get_singleton("TapsellGodot")
		log_message("پلاگین TapsellGodot با موفقیت بارگذاری شد.")
		
		# اتصال سیگنال‌های وضعیت اتصال
		tapsell_plugin.connect("init_success", Callable(self, "_on_init_success"))
		tapsell_plugin.connect("init_failed", Callable(self, "_on_init_failed"))
		
		# اتصال سیگنال‌های ویدیوی جایزه‌ای
		tapsell_plugin.connect("rewarded_video_response", Callable(self, "_on_rewarded_response"))
		tapsell_plugin.connect("rewarded_video_error", Callable(self, "_on_rewarded_error"))
		tapsell_plugin.connect("rewarded_video_opened", Callable(self, "_on_rewarded_opened"))
		tapsell_plugin.connect("rewarded_video_closed", Callable(self, "_on_rewarded_closed"))
		tapsell_plugin.connect("rewarded_video_rewarded", Callable(self, "_on_rewarded_rewarded"))
		
		# اتصال سیگنال‌های بنر ۳۲۰x۵۰
		tapsell_plugin.connect("banner_response", Callable(self, "_on_banner_response"))
		tapsell_plugin.connect("banner_error", Callable(self, "_on_banner_error"))
		tapsell_plugin.connect("banner_opened", Callable(self, "_on_banner_opened"))
		tapsell_plugin.connect("banner_closed", Callable(self, "_on_banner_closed"))
		
		update_status("در حال اتصال به تپسل...", Color.YELLOW)
		tapsell_plugin.initialize(APP_KEY)
	else:
		update_status("خطا: سینگلتون TapsellGodot یافت نشد!", Color.RED)
		log_message("خطا: مطمئن شوید تیک Use Gradle Build در تنظیمات خروجی فعال است.")

# ==========================================
# 📡 پاسخ‌های سیگنال‌ها (Callbacks)
# ==========================================

func _on_init_success(network_info: String) -> void:
	update_status("تپسل آماده و متصل است.", Color.GREEN)
	log_message("اتصال تپسل برقرار شد: " + network_info)
	btn_rewarded.disabled = false
	btn_banner.disabled = false
	btn_hide_banner.disabled = false

func _on_init_failed(error_msg: String) -> void:
	update_status("خطا در اتصال به تپسل: " + error_msg, Color.RED)
	log_message("Init Failed: " + error_msg)

func _on_rewarded_response(res_id: String) -> void:
	rewarded_response_id = res_id
	log_message("ویدیو با موفقیت لود شد (ID: " + res_id + "). در حال نمایش...")
	update_status("ویدیو جایزه‌ای آماده است.", Color.CYAN)
	if tapsell_plugin:
		tapsell_plugin.showRewardedVideo(rewarded_response_id)

func _on_rewarded_error(error_msg: String) -> void:
	update_status("خطا در ویدیو: " + error_msg, Color.RED)
	log_message("Rewarded Error: " + error_msg)
	btn_rewarded.disabled = false
	btn_rewarded.text = "🎥 دریافت و نمایش ویدیو جایزه‌ای"

func _on_rewarded_opened() -> void:
	update_status("ویدیو در حال پخش است...", Color.YELLOW)
	log_message("ویدیو باز شد.")

func _on_rewarded_closed() -> void:
	update_status("ویدیو بسته شد.", Color.WHITE)
	log_message("ویدیو بسته شد.")
	btn_rewarded.disabled = false
	btn_rewarded.text = "🎥 دریافت و نمایش ویدیو جایزه‌ای"

func _on_rewarded_rewarded() -> void:
	update_status("🎉 کاربر ویدیو را دید و جایزه را دریافت کرد!", Color.GREEN)
	log_message("🎉 تبریک! جایزه ویدیوی تبلیغاتی به بازیکن اهدا شد.")

func _on_banner_response(res_id: String) -> void:
	banner_response_id = res_id
	log_message("بنر ۳۲۰x۵۰ دریافت شد (ID: " + res_id + "). در حال نمایش...")
	update_status("بنر استاندارد آماده است.", Color.GREEN)
	btn_banner.disabled = false
	btn_banner.text = "📌 دریافت و نمایش بنر ۳۲۰x۵۰"
	if tapsell_plugin:
		tapsell_plugin.showBanner(banner_response_id)

func _on_banner_error(error_msg: String) -> void:
	update_status("خطا در بنر ۳۲۰x۵۰: " + error_msg, Color.RED)
	log_message("Banner Error: " + error_msg)
	btn_banner.disabled = false
	btn_banner.text = "📌 دریافت و نمایش بنر ۳۲۰x۵۰"

func _on_banner_opened() -> void:
	update_status("بنر ۳۲۰x۵۰ در پایین صفحه نمایش داده شد.", Color.GREEN)
	log_message("بنر ۳۲۰x۵۰ فعال شد.")

func _on_banner_closed() -> void:
	update_status("بنر بسته شد.", Color.WHITE)
	log_message("بنر بسته شد.")

# ==========================================
# 🔘 دکمه‌های رابط کاربری
# ==========================================

func _on_btn_rewarded_pressed() -> void:
	if not tapsell_plugin:
		return
	if REWARDED_ZONE_ID.strip_edges() == "":
		log_message("خطا: شناسه REWARDED_ZONE_ID وارد نشده است.")
		return
	btn_rewarded.disabled = true
	btn_rewarded.text = "در حال بارگذاری ویدیو..."
	update_status("در حال ارسال درخواست ویدیوی جایزه‌ای...", Color.YELLOW)
	tapsell_plugin.requestRewardedVideo(REWARDED_ZONE_ID)

func _on_btn_banner_pressed() -> void:
	if not tapsell_plugin:
		return
	if BANNER_ZONE_ID.strip_edges() == "":
		log_message("خطا: شناسه BANNER_ZONE_ID وارد نشده است.")
		return
	btn_banner.disabled = true
	btn_banner.text = "در حال دریافت بنر..."
	update_status("در حال ارسال درخواست بنر ۳۲۰x۵۰...", Color.YELLOW)
	tapsell_plugin.requestBanner(BANNER_ZONE_ID)

func _on_btn_hide_banner_pressed() -> void:
	if not tapsell_plugin:
		return
	tapsell_plugin.hideBanner()
	update_status("بنر از روی صفحه مخفی شد.", Color.WHITE)
	log_message("دستور بستن بنر ارسال شد.")

# ==========================================
# 🛠️ توابع کمکی
# ==========================================

func update_status(text: String, color: Color = Color.WHITE) -> void:
	if status_label:
		status_label.text = text
		status_label.modulate = color

func log_message(msg: String) -> void:
	var time_str = Time.get_time_string_from_system()
	var formatted_msg = "[" + time_str + "] " + msg
	print(formatted_msg)
	if log_display:
		log_display.text += formatted_msg + "\n"
		log_display.set_caret_line(log_display.get_line_count())
