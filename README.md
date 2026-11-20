# پلاگین تپسل پلاس برای گودو ۴ (Tapsell Plus Godot 4 Plugin)

این ریپازیتوری شامل یک افزونه آماده، سبک و استاندارد برای استفاده از شبکه تبلیغاتی **تپسل پلاس (Tapsell Plus SDK 2.3.3)** در موتور بازی‌سازی **Godot Engine 4.x** است.

این افزونه به طور اختصاصی روی دو نوع تبلیغ پرکاربرد متمرکز شده است:
1. **ویدیوی جایزه‌ای (Rewarded Video)**
2. **بنر استاندارد ۳۲۰x۵۰ (Standard Banner 320x50)**

---

## 🚀 ویژگی‌ها

- سازگار با **Godot 4.2 تا 4.7+** با سیستم Android Plugin v2
- استفاده از آخرین نسخه پایدار **Tapsell Plus SDK (2.3.3)**
- کدهای تمیز و مستقل بدون وابستگی‌های اضافی
- مدیریت خودکار لایه نمایش بنر بر روی سطح رندر گودو (`SurfaceView`)
- پشتیبانی کامل از رشته‌های پردازشی اندروید (`runOnUiThread`)
- اسکریپت آماده Singleton / Autoload به زبان GDScript
- سیستم تست زنده و مستقل درون پروژه

---

## 📂 ساختار فایل‌های ریپازیتوری

```text
Tapsel/
├── android/                             # قالب سفارشی بیلد اندروید (کدهای جاوا و گریدل)
│   ├── .build_version                   # تاییدیه نسخه گودو
│   ├── .gdignore                        # محافظت در برابر اسکن خودکار گودو
│   └── build/
│       ├── build.gradle                 # تنظیمات وابستگی Tapsell Plus و مخزن Maven
│       ├── gradle.properties            # تنظیم سازگاری نسخه کامپایل SDK
│       └── src/main/
│           ├── AndroidManifest.xml      # مجوزهای اینترنت، شبکه و شناسه تبلیغاتی
│           └── java/ir/tapsell/godot/
│               └── TapsellGodotPlugin.java # سورس کد اصلی پلاگین جاوا
├── scripts/
│   └── tapsell.gd                       # اسکریپت آماده مدیریت تپسل (Autoload)
├── main.gd                              # نمونه اسکریپت تست تعاملی
├── main.tscn                            # صحنه نمونه گرافیکی تست دکمه‌ها و رویدادها
├── project.godot                        # تنظیمات پیش‌فرض پروژه گودو
├── export_presets.cfg                   # تنظیمات آماده خروجی اندروید با Gradle Build
└── .gitignore                           # نادیده‌گرفتن فایل‌های موقت، کش و بیلد
```

---

## 🔑 تنظیم کلیدهای تپسل (Credentials Setup)

برای شروع، کلیدهای دریافت شده از [داشبورد تپسل](https://dashboard.tapsell.ir) را در فایل [`scripts/tapsell.gd`](file:///c:/Users/aa600/Desktop/test%20tapsel/Tapsel/scripts/tapsell.gd) (یا [`main.gd`](file:///c:/Users/aa600/Desktop/test%20tapsel/Tapsel/main.gd)) قرار دهید:

```gdscript
# کلیدهای اختصاصی خود را در این متغیرها قرار دهید:
const APP_KEY: String = "YOUR_TAPSELL_APP_KEY"
const REWARDED_ZONE_ID: String = "YOUR_REWARDED_ZONE_ID"
const BANNER_ZONE_ID: String = "YOUR_BANNER_320x50_ZONE_ID"
```

> 💡 **نکته جهت تست اولیه:** اگر هنوز کلید اختصاصی ندارید، می‌توانید از کلیدهای تستی رسمی تپسل برای بررسی کارکرد استفاده کنید:
> - Test AppKey: `alsoatsrtrotpqacegkehkaiieckldhrgsbspqtgqnbrrfccrtbdomgjtahflchkqtqosa`
> - Test Rewarded Zone: `5cfaa9deaede570001d55539`
> - Test Banner 320x50 Zone: `5cfaaa30e8d17f0001ffb294`

---

## 🛠️ نحوه اضافه کردن به پروژه موجود شما

اگر می‌خواهید این سیستم را به بازی یا پروژه فعلی خود اضافه کنید، تنها کافی است ۳ مرحله ساده زیر را انجام دهید:

### مرحله ۱: کپی پوشه `android`
پوشه `android` موجود در این ریپازیتوری را مستقیماً در ریشه پروژه گودوی خود کپی کنید.

### مرحله ۲: افزودن اسکریپت Autoload
فایل [`scripts/tapsell.gd`](file:///c:/Users/aa600/Desktop/test%20tapsel/Tapsel/scripts/tapsell.gd) را در پروژه خود قرار داده و در تنظیمات گودو:
**Project ➡️ Project Settings ➡️ Globals ➡️ Autoload**
آن را با نام `Tapsell` به صورت گلوبال ثبت کنید.

### مرحله ۳: فعال‌سازی Gradle Build در تنظیمات خروجی
در گودو به مسیر **Project ➡️ Export** بروید و در پریست Android مطمئن شوید گزینه:
`Use Gradle Build = On`
فعال باشد.

---

## 📖 راهنمای استفاده در کد بازی (Code Usage)

### ۱. ویدیوی جایزه‌ای (Rewarded Video)

```gdscript
# درخواست و نمایش ویدیو جایزه‌ای:
func watch_ad_for_reward() -> void:
    Tapsell.request_rewarded_video()

# در تابع _ready سیگنال‌ها را متصل کنید:
func _ready() -> void:
    Tapsell.rewarded_video_loaded.connect(_on_video_loaded)
    Tapsell.rewarded_video_completed.connect(_on_video_rewarded)

func _on_video_loaded(res_id: String) -> void:
    # نمایش خودکار یا فعال‌سازی دکمه نمایش
    Tapsell.show_rewarded_video(res_id)

func _on_video_rewarded() -> void:
    # کاربر ویدیو را تا انتها دیده است؛ پاداش را اهدا کنید:
    player_coins += 100
    print("سکه جایزه اضافه شد!")
```

### ۲. بنر استاندارد ۳۲۰x۵۰ (Standard Banner)

```gdscript
# درخواست و نمایش بنر در پایین صفحه:
func show_banner_ad() -> void:
    Tapsell.request_banner()

func _ready() -> void:
    Tapsell.banner_loaded.connect(_on_banner_loaded)

func _on_banner_loaded(res_id: String) -> void:
    Tapsell.show_banner(res_id)

# برای مخفی کردن و بستن بنر:
func hide_banner_ad() -> void:
    Tapsell.hide_banner()
```

---

## 📦 نحوه خروجی گرفتن APK

### از ادیتور گودو:
1. گوشی اندرویدی خود را از طریق USB متصل کنید (با قابلیت USB Debugging فعال).
2. در ادیتور گودو، روی آیکون Android در گوشه بالا سمت راست (One-Click Deploy) کلیک کنید یا از منوی **Project ➡️ Export ➡️ Android ➡️ Export Project** خروجی `.apk` را ذخیره کنید.

### از خط فرمان (Headless):
```powershell
godot --headless --export-debug "Android" "build/game.apk"
```

---

## ⚠️ نکات مهم و رفع خطاهای متداول

1. **چرا بنر نمایش داده نمی‌شود؟**
   - حتماً بررسی کنید که در پنل تپسل، نوع جایگاه تبلیغاتی دقیقاً **بنر استاندارد** با اندازه **۳۲۰x۵۰** انتخاب شده باشد. اگر نوع زون «همسان / Native» یا سایز دیگر انتخاب شده باشد، سرور تپسل درخواست بنر ۳۲۰x۵۰ را پاسخ نمی‌دهد.
   - پدیده **No-Fill**: در صورتی که در آن لحظه کمپین فعالی برای بنر وجود نداشته باشد، تپسل خطای عدم وجود موجودی بازمی‌گرداند. برای اطمینان از صحت کدها همیشه با زون تستی تست کنید.

2. **خطای فایل‌های `.import` در گریدل:**
   - فایل‌های `.gdignore` درون پوشه `android` و `android/build` قرار داده شده‌اند تا از اسکن اشتباه فایل‌های اندروید توسط گودو جلوگیری کنند. آنها را حذف نکنید.

3. **مجوزهای مانیفست:**
   - مجوزهای `INTERNET`، `ACCESS_NETWORK_STATE` و `AD_ID` قبلاً در فایل [`AndroidManifest.xml`](file:///c:/Users/aa600/Desktop/test%20tapsel/Tapsel/android/build/src/main/AndroidManifest.xml) تعریف شده‌اند و نیازی به تغییر دستی ندارند.

---

## 📄 لایسنس
این کدها تحت لایسنس MIT منتشر شده و برای پروژه‌های تجاری و شخصی کاملاً آزاد و رایگان است.
