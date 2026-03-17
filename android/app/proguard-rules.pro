# Custom ProGuard rules for the application.
# This file is used when building release APKs with minification (R8).

# Keep Stripe SDK push provisioning classes (used by react-native-stripe-sdk)
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }

# Keep Stripe core classes (to prevent R8 stripping required code)
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }

# Keep models/serializers used by Stripe
-keepclassmembers class com.stripe.android.** {
    <init>(...);
}

# Keep Kotlin metadata (required for reflection/serialization)
-keep class kotlin.Metadata { *; }
