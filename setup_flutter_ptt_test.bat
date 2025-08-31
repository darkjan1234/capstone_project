@echo off
echo ========================================
echo 🚀 FLUTTER PTT VOICE SYSTEM SETUP
echo ========================================
echo.

echo This will set up and test the complete Flutter PTT system:
echo ✅ Backend API with voice transmission
echo ✅ Flutter mobile app with real PTT functionality
echo ✅ Real-time voice communication over internet
echo.

set /p confirm="Continue with setup? (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo ========================================
echo Step 1: Setting up Backend Server
echo ========================================

echo Creating test users and starting backend...
call create_users_and_test_ptt.bat

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Backend setup failed!
    echo Please fix backend issues first.
    pause
    exit /b
)

echo.
echo ========================================
echo Step 2: Setting up Flutter App
echo ========================================

cd flutter_ptt_app

echo Installing Flutter dependencies...
flutter pub get

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter pub get failed!
    echo Make sure Flutter is installed and in PATH.
    pause
    exit /b
)

echo.
echo ✅ Flutter dependencies installed successfully!
echo.

echo ========================================
echo 🎯 FLUTTER PTT SYSTEM READY!
echo ========================================
echo.
echo 📱 Flutter App Features:
echo ✅ Real-time voice transmission
echo ✅ Push-to-Talk button
echo ✅ Multiple user support
echo ✅ Connection status
echo ✅ Activity logging
echo ✅ Online user list
echo.
echo 🌐 Backend Server:
echo ✅ Running on: https://localhost:44301
echo ✅ SignalR Hub: /signalr-ptt-voice
echo ✅ Test users created (admin, john, user)
echo.
echo ========================================
echo 🎯 HOW TO TEST PTT VOICE TRANSMISSION:
echo ========================================
echo.
echo 1. BACKEND: Already running in background
echo.
echo 2. FLUTTER APP:
echo    - Run: flutter run
echo    - Or open in Android Studio/VS Code
echo    - Choose emulator or physical device
echo.
echo 3. TESTING:
echo    - Login with: admin, john, or user
echo    - Allow microphone permission
echo    - Hold PTT button and speak
echo    - Test with multiple devices/emulators
echo.
echo 4. MULTIPLE USERS:
echo    - Run app on different devices
echo    - Or use multiple emulators
echo    - Each user can transmit and receive
echo.
echo ========================================
echo 📱 FLUTTER COMMANDS:
echo ========================================
echo.
echo Run on Android Emulator:
echo   flutter run
echo.
echo Run on specific device:
echo   flutter devices
echo   flutter run -d [device-id]
echo.
echo Build APK for testing:
echo   flutter build apk
echo.
echo ========================================
echo 🔊 TESTING CHECKLIST:
echo ========================================
echo.
echo ✅ Backend server running (check console)
echo ✅ Flutter app compiled successfully
echo ✅ Microphone permission granted
echo ✅ Multiple users connected
echo ✅ PTT button working (hold to talk)
echo ✅ Voice transmission working
echo ✅ Voice reception working
echo ✅ Activity log showing events
echo.
echo Ready to test! Run: flutter run
echo.
pause
