# ۲. معماری پلاگین اندروید و کدهای بومی جاوا (Android Plugin Architecture)

## ۲.۱ ساختار پلاگین‌های گودو ۴ (Godot Plugin v2)
در نسخه ۴ موتور گودو، سیستم افزونه‌های بومی اندروید از کلاس پایه `org.godotengine.godot.plugin.GodotPlugin` مشتق می‌شود:

1. **شناسه پلاگین (`getPluginName`)**: نام یکتایی که پلاگین با آن در GDScript شناخته می‌شود (`TapsellGodot`).
2. **سیگنال‌ها (`getPluginSignals`)**: تعریف رویدادهایی که از سمت جاوا به گودو مخابره می‌شوند.
3. **توابع در دسترس (`@UsedByGodot`)**: انوتیشنی که گودو را قادر می‌سازد توابع جاوای این کلاس را از طریق رفلکشن شناسایی و فراخوانی کند.
4. **مدیریت رشته‌های پردازشی (Thread Management)**: گودو کدهای بازی را روی رشته رندر (GL Thread) اجرا می‌کند، در حالی که تمام متدهای نمایشی اندروید و SDK تپسل الزماً باید روی رشته اصلی رابط کاربری اجرا شوند:
   ```java
   activity.runOnUiThread(() -> {
       // کدهای مربوط به SDK تپسل و مدیریت Viewها
   });
   ```

---

## ۲.۲ کدهای منبع جاوا (`TapsellGodotPlugin.java`)

مسیر فایل: [`android/build/src/main/java/ir/tapsell/godot/TapsellGodotPlugin.java`](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/android/build/src/main/java/ir/tapsell/godot/TapsellGodotPlugin.java)

### ۲.۲.۱ بخش مقداردهی اولیه (Initialization)
```java
@UsedByGodot
public void initialize(String appKey) {
    Activity activity = getActivity();
    activity.runOnUiThread(() -> {
        TapsellPlus.setDebugMode(Log.DEBUG); // فعال‌سازی لاگ‌های کامل در Logcat
        TapsellPlus.initialize(activity, appKey, new TapsellPlusInitListener() {
            @Override
            public void onInitializeSuccess(AdNetworks adNetworks) {
                emitSignal("init_success", adNetworks != null ? adNetworks.toString() : "Success");
            }

            @Override
            public void onInitializeFailed(AdNetworks adNetworks, AdNetworkError adNetworkError) {
                String errMsg = adNetworkError != null ? adNetworkError.getErrorMessage() : "Unknown error";
                emitSignal("init_failed", errMsg);
            }
        });
    });
}
```

### ۲.۲.۲ بخش ویدیو جایزه‌ای (Rewarded Video)
فرآیند نمایش تبلیغ ویدیویی جایزه‌ای در دو مرحله انجام می‌پذیرد:
1. **درخواست (`requestRewardedVideo`)**: تپسل در صورت وجود تبلیغ، یک شناسه یکتا به نام `responseId` بازمی‌گرداند و سیگنال `rewarded_video_response` فعال می‌شود.
2. **نمایش (`showRewardedVideo`)**: با ارسال شناسه دریافتی، ویدیو به صورت تمام‌صفحه باز می‌شود و لیسنر مربوطه رویدادهای زیر را پایش می‌کند:
   - `onOpened` ⬅️ ارسال سیگنال `rewarded_video_opened`
   - `onClosed` ⬅️ ارسال سیگنال `rewarded_video_closed`
   - `onRewarded` ⬅️ ارسال سیگنال `rewarded_video_rewarded` (لحظه اعطای جایزه به بازیکن)
   - `onError` ⬅️ ارسال سیگنال `rewarded_video_error`

### ۲.۲.۳ بخش بنر استاندارد (Standard Banner)
برای نمایش بنر بر روی سطح رندر گودو:
- یک کانتینر `FrameLayout` به ریشه رابط کاربری اکتیویتی (`android.R.id.content`) اضافه می‌شود.
- متد `bannerContainer.bringToFront()` فراخوانی می‌شود تا مطمئن شویم بنر روی رندر `SurfaceView` گودو پوشانده نمی‌شود.
- متد `requestStandardBannerWithType(zoneId, typeIndex)` سایز بنر را مشخص می‌کند:
  - ایندکس `0`: سایز `BANNER_320x50`
  - ایندکس `1`: سایز `BANNER_300x250`
  - ایندکس `2`: سایز `BANNER_320x100`
  - ایندکس `3`: سایز `BANNER_250x250`
- متد `destroyStandardBanner()` بنر را آزاد کرده و کانتینر را از صفحه پاک می‌کند.

### ۲.۲.۴ بخش بنر همسان (Native Banner)
تپسل پلاس قالب آماده‌ای تحت عنوان `res/layout/native_banner.xml` درون فایل AAR خود دارد. در صورتی که زون تبلیغاتی کاربر از نوع «همسان» باشد:
- از متد `TapsellPlus.createAdHolder(...)` استفاده می‌شود.
- سپس با `TapsellPlus.showNativeAd(...)` بنر همراه با عنوان، توضیحات، آیکون و دکمه دانلود نمایش داده می‌شود.

---

## ۲.۳ تنظیمات Gradle (`build.gradle`)

مسیر فایل: [`android/build/build.gradle`](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/android/build/build.gradle)

### مخازن (Repositories):
برای دریافت SDK تپسل، مخزن اختصاصی شرکت تپسل در بلوک `allprojects/repositories` اضافه شده است:
```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://maven.tapsell.ir" }
    }
}
```

### وابستگی‌ها (Dependencies):
کتابخانه تپسل پلاس به بلوک `dependencies` پروژه اندروید اضافه شده است:
```groovy
dependencies {
    implementation 'ir.tapsell.plus:tapsell-plus-sdk-android:2.3.3'
}
```

---

## ۲.۴ تنظیمات مانیفست اندروید (`AndroidManifest.xml`)

مسیر فایل: [`android/build/src/main/AndroidManifest.xml`](file:///c:/Users/aa600/Desktop/test%20tapsel/test-tapsel/android/build/src/main/AndroidManifest.xml)

### ۱. مجوزهای دسترسی (Permissions):
```xml
<!-- دسترسی به اینترنت جهت دریافت تبلیغات -->
<uses-permission android:name="android.permission.INTERNET" />
<!-- بررسی اتصال شبکه و وضعیت اینترنت -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<!-- دریافت شناسه تبلیغاتی گوگل جهت هدف‌گذاری در اندروید ۱۲ به بالا -->
<uses-permission android:name="com.google.android.gms.permission.AD_ID" />
```

### ۲. معرفی پلاگین به گودو:
درون تگ `<application>` متادیتای زیر قرار دارد تا لودر گودو پلاگین جاوا را شناسایی و بارگذاری کند:
```xml
<meta-data
    android:name="org.godotengine.plugin.v2.TapsellGodot"
    android:value="ir.tapsell.godot.TapsellGodotPlugin" />
```

### ۳. ترافیک متنی (Cleartext Traffic):
جهت جلوگیری از انسداد درخواست‌های لود رسانه‌ها یا تصاویر در برخی شبکه‌ها:
```xml
<application
    android:usesCleartextTraffic="true"
    ... >
```
