# ۳. مرجع توابع، سیگنال‌ها و اسکریپت GDScript (API Reference)

در این بخش، کلیه توابع جاوا که از سمت GDScript قابل فراخوانی هستند و همچنین سیگنال‌هایی که پلاگین ارسال می‌کند به همراه نمونه کد تشریح شده‌اند.

---

## ۳.۱ نحوه دریافت سینگلتون در گودو

برای برقراری ارتباط با پلاگین در اسکریپت‌های بازی، ابتدا باید از وجود سینگلتون اطمینان حاصل کنید:

```gdscript
var tapsell_plugin = null

func _ready() -> void:
    if OS.get_name() == "Android" and Engine.has_singleton("TapsellGodot"):
        tapsell_plugin = Engine.get_singleton("TapsellGodot")
        connect_signals()
        tapsell_plugin.initialize("YOUR_TAPSELL_APP_KEY")
    else:
        print("پلاگین تپسل در این محیط در دسترس نیست.")
```

---

## ۳.۲ توابع قابل فراخوانی (Callable Methods)

کلیه این توابع از طریق شیء `tapsell_plugin` در دسترس هستند:

### ۱. مقداردهی اولیه
| تابع | نوع آرگومان‌ها | توضیحات |
| :--- | :--- | :--- |
| `initialize(appKey)` | `appKey: String` | مقداردهی اولیه SDK تپسل با کلید اپلیکیشن |
| `setDebugMode(mode)` | `mode: int` | تنظیم سطح لاگ (مثلاً `3` برای لاگ دیباگ کامل) |

### ۲. ویدیوی جایزه‌ای (Rewarded Video)
| تابع | نوع آرگومان‌ها | توضیحات |
| :--- | :--- | :--- |
| `requestRewardedVideo(zoneId)` | `zoneId: String` | ارسال درخواست ویدیو جایزه‌ای به سرور تپسل برای زون مشخص |
| `showRewardedVideo(responseId)` | `responseId: String` | نمایش ویدیو جایزه‌ای دریافت شده به صورت فول‌اسکرین |

> **نکته:** اگر پارامتر `responseId` به صورت رشته خالی `""` ارسال شود، پلاگین به صورت خودکار از آخرین `responseId` دریافت شده استفاده می‌کند.

### ۳. بنر استاندارد (Standard Banner)
| تابع | نوع آرگومان‌ها | توضیحات |
| :--- | :--- | :--- |
| `requestStandardBanner(zoneId)` | `zoneId: String` | درخواست بنر استاندارد ۳۲۰x۵۰ (سایز پیش‌فرض) |
| `requestStandardBannerWithType(zoneId, typeIndex)` | `zoneId: String`, `typeIndex: int` | درخواست بنر با انتخاب سایز دلخواه: <br>`0` = ۳۲۰x۵۰ <br>`1` = ۳۰۰x۲۵۰ (مستطیلی) <br>`2` = ۳۲۰x۱۰۰ <br>`3` = ۲۵۰x۲۵۰ |
| `showStandardBanner(responseId)` | `responseId: String` | ایجاد کانتینر و نمایش بنر استاندارد در پایین صفحه |
| `destroyStandardBanner()` | بدون آرگومان | مخفی‌سازی و حذف کامل بنر استاندارد از روی صفحه |

### ۴. بنر همسان (Native Banner)
| تابع | نوع آرگومان‌ها | توضیحات |
| :--- | :--- | :--- |
| `requestNativeBanner(zoneId)` | `zoneId: String` | ارسال درخواست بنر همسان برای زون مشخص |
| `showNativeBanner(responseId)` | `responseId: String` | رندر و نمایش بنر همسان در کانتینر پایین صفحه |
| `destroyNativeBanner()` | بدون آرگومان | مخفی‌سازی و حذف بنر همسان از روی صفحه |

---

## ۳.۳ سیگنال‌های ارسالی به گودو (Signals)

این سیگنال‌ها باید در کد GDScript با متد `.connect(...)` متصل شوند:

### ۱. سیگنال‌های وضعیت اتصال (Initialization)
- `init_success(network_info: String)`: اتصال موفقیت‌آمیز به تپسل.
- `init_failed(error_msg: String)`: خطا در اتصال به تپسل.

### ۲. سیگنال‌های ویدیو جایزه‌ای (Rewarded Video)
- `rewarded_video_response(res_id: String)`: ویدیو با موفقیت لود شد و آماده نمایش است.
- `rewarded_video_error(error_msg: String)`: خطا در دریافت یا باز کردن ویدیو.
- `rewarded_video_opened()`: ویدیو باز شده و در حال پخش برای کاربر است.
- `rewarded_video_closed()`: پنجره ویدیو توسط کاربر بسته شد.
- `rewarded_video_rewarded()`: **مهم‌ترین سیگنال!** کاربر تا انتهای ویدیو را تماشا کرده و باید سکه، جان یا پاداش بازی به او اهدا شود.

### ۳. سیگنال‌های بنر استاندارد (Standard Banner)
- `banner_response(res_id: String)`: بنر استاندارد با موفقیت لود شد.
- `banner_error(error_msg: String)`: خطا در لود بنر استاندارد (مثلاً No Fill یا عدم تطابق زون).
- `banner_opened()`: بنر بر روی صفحه به نمایش درآمد.
- `banner_closed()`: بنر بسته شد.

### ۴. سیگنال‌های بنر همسان (Native Banner)
- `native_banner_response(res_id: String)`: بنر همسان با موفقیت لود شد.
- `native_banner_error(error_msg: String)`: خطا در لود بنر همسان.
- `native_banner_opened()`: بنر همسان بر روی صفحه به نمایش درآمد.
- `native_banner_closed()`: بنر همسان بسته شد.

---

## ۳.۴ کد نمونه اتصال و استفاده در اسکریپت بازی

در فایل [`main.gd`](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/main.gd) نحوه اتصال کامل به این صورت پیاده‌سازی شده است:

```gdscript
func init_tapsell_plugin() -> void:
    tapsell_plugin = Engine.get_singleton("TapsellGodot")
    
    # اتصال سیگنال‌های ویدیو
    tapsell_plugin.connect("rewarded_video_response", Callable(self, "_on_rewarded_response"))
    tapsell_plugin.connect("rewarded_video_error", Callable(self, "_on_rewarded_error"))
    tapsell_plugin.connect("rewarded_video_rewarded", Callable(self, "_on_rewarded_rewarded"))
    
    # اتصال سیگنال‌های بنر
    tapsell_plugin.connect("banner_response", Callable(self, "_on_banner_response"))
    tapsell_plugin.connect("banner_error", Callable(self, "_on_banner_error"))
    
    # شروع اولیه تپسل
    tapsell_plugin.initialize("YOUR_APP_KEY")

func _on_rewarded_response(res_id: String) -> void:
    print("ویدیو آماده شد، در حال نمایش...")
    tapsell_plugin.showRewardedVideo(res_id)

func _on_rewarded_rewarded() -> void:
    print("جایزه به بازیکن اضافه شد!")
    player_coins += 100

func _on_banner_response(res_id: String) -> void:
    print("بنر آماده شد، نمایش در پایین صفحه...")
    tapsell_plugin.showStandardBanner(res_id)
```
