# Flutter 기본 설정
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Mobile Ads (AdMob) SDK 보호
-keep public class com.google.android.gms.ads.** {
   public *;
}
-keep public class com.google.ads.** {
   public *;
}

# AndroidX 및 기타 필수 클래스
-keep class com.google.android.gms.** { *; }

# For Google Mobile Ads SDK (Comprehensive)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep class com.google.android.gms.internal.** { *; }

# 추가 클래스 보호 (R8 충돌 방지)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.android.gms.common.annotation.KeepName { *; }
-keepnames class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# For general GMS stability
-dontwarn com.google.android.gms.**
-dontwarn com.google.ads.**

# 경고 무시 및 강제 진행 (persistent R8 오류 해결용)
-ignorewarnings
-dontnote **
