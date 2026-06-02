# Permissions and Manifest Notes

After adding `permission_handler` and Hive, you must update platform files:

Android (android/app/src/main/AndroidManifest.xml):

Add permissions:

<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

iOS (ios/Runner/Info.plist):

Add keys with usage descriptions:

- NSCameraUsageDescription
- NSLocationWhenInUseUsageDescription
- NSMotionUsageDescription (if using pedometer)

Additionally, for `permission_handler` on Android 12+ you may need to add
queries or provider entries; consult permission_handler docs.
