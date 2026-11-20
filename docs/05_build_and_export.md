# ۵. راهنمای بیلد و خروجی پکیج اندروید (Build & Export Guide)

این راهنما مراحل کامل آماده‌سازی محیط و نحوه گرفتن خروجی APK را به دو روش رابط کاربری گودو و خط فرمان شرح می‌دهد.

---

## ۵.۱ پیش‌نیازهای سیستمی (Prerequisites)

برای گرفتن خروجی اندروید با قابلیت Gradle Build، موارد زیر باید روی سیستم نصب و تنظیم شده باشند:

1. **جاوا (Java Development Kit - JDK 17)**:
   - متغیر محیطی `JAVA_HOME` باید به مسیر نصب JDK 17 اشاره کند.
2. **اندروید اس‌دی‌کی (Android SDK)**:
   - پلتفرم‌های SDK نسخه ۳۴ یا ۳۵
   - ابزارهای ساخت (Android SDK Build-Tools)
   - پلتفرم تولز (`adb`)
3. **فایل `local.properties`**:
   - در مسیر [`android/build/local.properties`](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/android/build/local.properties) باید آدرس دقیق نصب SDK در سیستم وارد شده باشد:
     ```properties
     sdk.dir=C:/Users/aa600/AppData/Local/Android/Sdk
     ```

---

## ۵.۲ تنظیمات پریست خروجی اندروید (`export_presets.cfg`)

پیکربندی‌های کلیدی ذخیره شده در فایل [`export_presets.cfg`](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/export_presets.cfg):
- **Gradle Build**: به صورت فعال (`gradle_build/use_gradle_build=true`) تنظیم شده تا کدهای جاوای پلاگین تپسل در حین ساخت کامپایل شوند.
- **شناسه پکیج (Package Unique Name)**: `com.pixic.vareh`
- **فیلتر مستثنی‌سازی (Exclude Filter)**: مقدار `android/*, build/*` قرار داده شده تا فایل‌های بیلد و منابع جاوا به داخل فایل `.pck` گودو نریزند و تداخل ایجاد نکنند.
- **معماری‌های پشتیبانی‌شده**: `arm64-v8a` و `armeabi-v7a` برای سازگاری حداکثری با تمام گوشی‌های اندرویدی.

---

## ۵.۳ روش‌های گرفتن خروجی APK

### روش اول: خروجی از طریق رابط ادیتور گودو (GUI)
1. ادیتور گودو ۴ را باز کنید.
2. از منوی بالا به مسیر **Project ➡️ Export** بروید.
3. پریست **Android** را انتخاب کنید.
4. دکمه **Export Project...** را بزنید.
5. مسیر ذخیره را مشخص کنید (تیک گزینه Export With Debug در صورت تست فعال باشد) و روی **Save** کلیک کنید.

---

### روش دوم: خروجی بدون رابط کاربری و از طریق خط فرمان (Headless CLI)
این روش سریع‌ترین راه برای کامپایل و اتوماسیون است:

```powershell
& "C:\Users\aa600\Downloads\Compressed\Godot_v4.6-stable_mono_win64\Godot_v4.7.2-stable_win64_console.exe" `
    --headless `
    --path "c:\Users\aa600\Desktop\test tapsel\test-tapsel" `
    --export-debug "Android" "c:\Users\aa600\Desktop\test tapsel\test-tapsel\build\test_tapsel.apk"
```

---

### روش سوم: کامپایل مستقل کدهای جاوا با گریدل (Gradle Direct)
در صورتی که فقط کدهای جاوا یا فایل‌های اندروید را ویرایش کرده‌اید و می‌خواهید از صحت نحوه کامپایل مطمئن شوید:

```cmd
cd "c:\Users\aa600\Desktop\test tapsel\test-tapsel\android\build"
gradlew.bat compileStandardDebugSources
```
در صورت موفقیت آمیز بودن، عبارت `BUILD SUCCESSFUL` نمایش داده می‌شود.

---

## ۵.۴ نصب و مشاهده لاگ‌ها روی گوشی با ADB

### ۱. نصب مستقیم روی گوشی متصل به کامپیوتر:
```bash
adb install -r "c:\Users\aa600\Desktop\test tapsel\test-tapsel\build\test_tapsel.apk"
```

### ۲. پایش لاگ‌های زنده تپسل و گودو (Logcat):
برای مشاهده دقیق رویدادهای ارسالی تپسل و اشکال‌زدایی در ترمینال:
```bash
adb logcat -s TapsellGodot TapsellPlus godot
```
این دستور تنها لاگ‌های مربوط به تپسل و گودو را فیلتر کرده و علت هرگونه خطا یا موفقیت را به صورت بلادرنگ به شما نشان می‌دهد.
