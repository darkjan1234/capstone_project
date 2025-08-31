@echo off
echo ========================================
echo 🔧 COMPLETE FLUTTER PTT FIX
echo ========================================
echo.

echo This will completely fix your Flutter setup and create a working PTT app.
echo.

set /p confirm="Fix Flutter and create PTT app? (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Step 1: Checking Flutter installation...
flutter doctor

echo.
echo Step 2: Stopping all processes...
taskkill /f /im java.exe 2>nul
taskkill /f /im gradle.exe 2>nul
taskkill /f /im adb.exe 2>nul

echo.
echo Step 3: Clearing caches...
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
    echo ✅ Gradle cache cleared
)

echo.
echo Step 4: Creating new Flutter project...
cd D:\capstone
flutter create ptt_mobile_app

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to create Flutter project!
    echo Run: flutter doctor
    pause
    exit /b
)

cd ptt_mobile_app

echo.
echo Step 5: Setting up dependencies...

REM Create pubspec.yaml
echo name: ptt_mobile_app > pubspec.yaml
echo description: PTT Voice Transmission Mobile App >> pubspec.yaml
echo publish_to: 'none' >> pubspec.yaml
echo version: 1.0.0+1 >> pubspec.yaml
echo. >> pubspec.yaml
echo environment: >> pubspec.yaml
echo   sdk: '>=3.0.0 ^<4.0.0' >> pubspec.yaml
echo. >> pubspec.yaml
echo dependencies: >> pubspec.yaml
echo   flutter: >> pubspec.yaml
echo     sdk: flutter >> pubspec.yaml
echo   http: ^1.1.0 >> pubspec.yaml
echo   cupertino_icons: ^1.0.2 >> pubspec.yaml
echo. >> pubspec.yaml
echo dev_dependencies: >> pubspec.yaml
echo   flutter_test: >> pubspec.yaml
echo     sdk: flutter >> pubspec.yaml
echo   flutter_lints: ^3.0.0 >> pubspec.yaml
echo. >> pubspec.yaml
echo flutter: >> pubspec.yaml
echo   uses-material-design: true >> pubspec.yaml

echo.
echo Step 6: Installing dependencies...
flutter clean
flutter pub get

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to install dependencies!
    pause
    exit /b
)

echo.
echo Step 7: Setting up PTT app code...
copy ..\simple_ptt_main.dart lib\main.dart

echo.
echo Step 8: Updating Android permissions...

REM Create Android manifest
echo ^<manifest xmlns:android="http://schemas.android.com/apk/res/android"^> > android\app\src\main\AndroidManifest.xml
echo     ^<uses-permission android:name="android.permission.INTERNET" /^> >> android\app\src\main\AndroidManifest.xml
echo     ^<application >> android\app\src\main\AndroidManifest.xml
echo         android:label="PTT Mobile App" >> android\app\src\main\AndroidManifest.xml
echo         android:name="${applicationName}" >> android\app\src\main\AndroidManifest.xml
echo         android:icon="@mipmap/ic_launcher" >> android\app\src\main\AndroidManifest.xml
echo         android:usesCleartextTraffic="true"^> >> android\app\src\main\AndroidManifest.xml
echo         ^<activity >> android\app\src\main\AndroidManifest.xml
echo             android:name=".MainActivity" >> android\app\src\main\AndroidManifest.xml
echo             android:exported="true" >> android\app\src\main\AndroidManifest.xml
echo             android:launchMode="singleTop" >> android\app\src\main\AndroidManifest.xml
echo             android:theme="@style/LaunchTheme"^> >> android\app\src\main\AndroidManifest.xml
echo             ^<intent-filter android:autoVerify="true"^> >> android\app\src\main\AndroidManifest.xml
echo                 ^<action android:name="android.intent.action.MAIN"/^> >> android\app\src\main\AndroidManifest.xml
echo                 ^<category android:name="android.intent.category.LAUNCHER"/^> >> android\app\src\main\AndroidManifest.xml
echo             ^</intent-filter^> >> android\app\src\main\AndroidManifest.xml
echo         ^</activity^> >> android\app\src\main\AndroidManifest.xml
echo     ^</application^> >> android\app\src\main\AndroidManifest.xml
echo ^</manifest^> >> android\app\src\main\AndroidManifest.xml

echo.
echo ========================================
echo ✅ FLUTTER PTT APP READY!
echo ========================================
echo.
echo Project: ptt_mobile_app
echo Location: D:\capstone\ptt_mobile_app
echo.
echo 🎯 NEXT STEPS:
echo.
echo 1. START BACKEND:
echo    - Make sure your PTT server is running
echo    - Check: https://localhost:44301/api/PttTest/check-database
echo.
echo 2. RUN FLUTTER APP:
echo    - Command: flutter run
echo    - Or: flutter run -d [device-id]
echo.
echo 3. TEST CONNECTION:
echo    - Login with: admin, john, or user
echo    - Check connection status
echo    - Test PTT button
echo.
echo 4. TROUBLESHOOTING:
echo    - Android Emulator: uses 10.0.2.2:44301
echo    - Physical Device: change IP in main.dart
echo    - Check flutter devices for available devices
echo.
echo Available commands:
echo   flutter devices    - Show available devices
echo   flutter run        - Run on default device
echo   flutter run -d ID  - Run on specific device
echo.
echo Ready to test! 🚀
pause
