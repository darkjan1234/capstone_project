@echo off
echo ========================================
echo 🔧 FIXING FLUTTER PTT AND TESTING
echo ========================================
echo.

echo This will fix the Gradle issues and create a working Flutter PTT app.
echo.

set /p confirm="Fix and test Flutter PTT? (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Step 1: Stopping all Gradle processes...

REM Kill any running Gradle processes
taskkill /f /im java.exe 2>nul
taskkill /f /im gradle.exe 2>nul

echo ✅ Gradle processes stopped

echo.
echo Step 2: Creating new Flutter project...

REM Create new Flutter project
flutter create ptt_voice_app

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to create Flutter project!
    echo Make sure Flutter is installed: flutter doctor
    pause
    exit /b
)

echo ✅ Flutter project created

echo.
echo Step 3: Setting up PTT app...

cd ptt_voice_app

REM Copy our simple PTT main.dart
copy ..\simple_flutter_ptt_main.dart lib\main.dart

REM Update pubspec.yaml to add HTTP dependency
echo name: ptt_voice_app > pubspec.yaml
echo description: PTT Voice System >> pubspec.yaml
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

echo ✅ PTT app configured

echo.
echo Step 4: Installing dependencies...

flutter clean
flutter pub get

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to install dependencies!
    pause
    exit /b
)

echo ✅ Dependencies installed

echo.
echo Step 5: Updating Android permissions...

REM Update Android manifest for internet permission
echo ^<manifest xmlns:android="http://schemas.android.com/apk/res/android"^> > android\app\src\main\AndroidManifest.xml
echo     ^<uses-permission android:name="android.permission.INTERNET" /^> >> android\app\src\main\AndroidManifest.xml
echo     ^<application >> android\app\src\main\AndroidManifest.xml
echo         android:label="PTT Voice App" >> android\app\src\main\AndroidManifest.xml
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

echo ✅ Android permissions updated

echo.
echo ========================================
echo ✅ FLUTTER PTT APP READY!
echo ========================================
echo.
echo Project: ptt_voice_app
echo Location: %CD%
echo.
echo 🎯 TESTING INSTRUCTIONS:
echo.
echo 1. BACKEND: Make sure your backend is running
echo    - Run: start_ptt_voice_system.bat
echo    - Check: https://localhost:44301/api/PttTest/check-database
echo.
echo 2. FLUTTER: Run the app
echo    - Command: flutter run
echo    - Or: flutter run -d [device-id]
echo.
echo 3. TEST CONNECTION:
echo    - App will try to connect to backend
echo    - Check connection status in app
echo    - Test PTT button functionality
echo.
echo 4. TROUBLESHOOTING:
echo    - If connection fails, check backend URL
echo    - For Android emulator: uses 10.0.2.2:44301
echo    - For physical device: use your computer's IP
echo.
echo Ready to test! Run: flutter run
echo.
pause
