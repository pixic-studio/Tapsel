# مستندات پروژه تست تپسل در گودو ۴ (Tapsell Plus Godot 4 Integration)

این مستندات شامل راهنمای جامع معماری، نحوه پیاده‌سازی، مرجع توابع، رفع اشکال و نحوه گرفتن خروجی اندروید برای ادغام **تپسل پلاس (Tapsell Plus SDK 2.3.3)** در **موتور بازی‌سازی گودو نسخه ۴ (Godot Engine 4.7+)** می‌باشد.

---

## 📚 فهرست سرفصل‌های مستندات

1. [**معرفی کلی پروژه و تنظیمات کلیدی**](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/docs/01_overview_and_setup.md)
   - هدف پروژه و پلتفرم‌های هدف
   - مشخصات کلیدهای تپسل (AppKey و Zone IDs)
   - ساختار پوشه‌ها و فایل‌های پروژه

2. [**معماری پلاگین اندروید و تنظیمات گریدل**](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/docs/02_android_plugin_architecture.md)
   - معماری Godot Android Plugin v2
   - شرح کد منبع جاوا ([`TapsellGodotPlugin.java`](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/android/build/src/main/java/ir/tapsell/godot/TapsellGodotPlugin.java))
   - تنظیم مخزن Maven و وابستگی‌های Tapsell Plus در گریدل
   - دسترسی‌ها و متادیتای مانیفست اندروید ([`AndroidManifest.xml`](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/android/build/src/main/AndroidManifest.xml))
   - نحوه تزریق لایوت‌های بنر روی لایه رندر گودو (`SurfaceView`)

3. [**مرجع توابع، سیگنال‌ها و اسکریپت GDScript**](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/docs/03_gdscript_api_reference.md)
   - توابع در دسترس جاوا از سمت گودو (`@UsedByGodot`)
   - لیست کامل سیگنال‌ها (Signals) و آرگومان‌های ارسالی
   - کد نمونه و تشریح بخش‌های مختلف [`main.gd`](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/main.gd)
   - سیستم لاگ‌گیری و گزارش خطای زنده روی صفحه

4. [**راهنمای عیب‌یابی، مشکلات بنر و خطاهای رایج**](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/docs/04_troubleshooting_and_faq.md)
   - چرا ویدیو دریافت می‌شد ولی بنر دریافت نمی‌شد؟ (بررسی تفاوت زون‌ها، سایز و No-Fill)
   - تفاوت بنر استاندارد (Standard Banner) و بنر همسان (Native Banner)
   - حل خطای فایل‌های `.import` در فرآیند ادغام منابع اندروید (`mergeStandardDebugResources`)
   - رفع اخطار `compileSdk = 36` و تنظیم `android.suppressUnsupportedCompileSdk`
   - رفع خطای فشرده‌سازی بافت‌ها (`ETC2/ASTC`)

5. [**راهنمای خروجی گرفتن و ساخت APK**](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/docs/05_build_and_export.md)
   - پیش‌نیازهای محیطی (Java JDK 17, Android SDK, NDK)
   - خروجی از طریق محیط گرافیکی ادیتور گودو
   - خروجی با خط فرمان (Headless CLI)
   - کامپایل دستی کدهای جاوا با گریدل

---

## ⚡ خلاصه وضعیت پروژه

| آیتم | مقدار | وضعیت |
| :--- | :--- | :--- |
| **موتور بازی‌سازی** | Godot Engine 4.7.2 stable | ✅ کاملاً سازگار |
| **پلتفرم** | Android (API 24 تا 36) | ✅ فعال (با بررسی `OS.get_name()`) |
| **نسخه SDK تپسل** | Tapsell Plus 2.3.3 | ✅ نصب و سینک شده |
| **ویدیو جایزه‌ای (Rewarded)** | زون اختصاصی شما (`YOUR_REWARDED_ZONE_ID`) | ✅ تست شده و فعال |
| **بنر تبلیغاتی (Banner)** | زون استاندارد ۳۲۰x۵۰ شما (`YOUR_BANNER_ZONE_ID`) | ✅ پشتیبانی از استاندارد ۳۲۰x۵۰ |
| **زون‌های تست رسمی تپسل** | Banner: `5cfaaa30e8d17f0001ffb294` | ✅ در دسترس جهت تست |
