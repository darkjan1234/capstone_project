@echo off
echo ========================================
echo 🔐 UPDATING FLUTTER WITH REAL AUTHENTICATION
echo ========================================
echo.

echo This will update your Flutter app to use real user accounts
echo from your admin panel (http://localhost:4200/app/admin/users)
echo.

set /p confirm="Update Flutter with real authentication? (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Step 1: Checking if Flutter project exists...

if not exist "D:\capstone\ptt_mobile_app" (
    echo ❌ Flutter project not found!
    echo Please run: complete_flutter_fix.bat first
    pause
    exit /b
)

cd D:\capstone\ptt_mobile_app

echo ✅ Flutter project found

echo.
echo Step 2: Backing up current main.dart...
if exist "lib\main.dart" (
    copy "lib\main.dart" "lib\main_backup.dart"
    echo ✅ Backup created: lib\main_backup.dart
)

echo.
echo Step 3: Updating with real authentication...
copy "..\flutter_real_auth_main.dart" "lib\main.dart"

if %ERRORLEVEL% EQU 0 (
    echo ✅ Authentication code updated successfully!
) else (
    echo ❌ Failed to update authentication code
    pause
    exit /b
)

echo.
echo Step 4: Cleaning and rebuilding...
flutter clean
flutter pub get

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to install dependencies!
    pause
    exit /b
)

echo.
echo ========================================
echo ✅ FLUTTER REAL AUTHENTICATION READY!
echo ========================================
echo.
echo 🔐 Authentication Features:
echo ✅ Real login with username/password
echo ✅ Connects to your backend API
echo ✅ Uses accounts from admin panel
echo ✅ Shows user role and region
echo ✅ Proper error handling
echo ✅ Connection status checking
echo.
echo 👥 Test with these accounts:
echo • admin / 123qwe (Super Admin)
echo • john / 123qwe (Field User)  
echo • user / 123qwe (Field User)
echo • Any account from: http://localhost:4200/app/admin/users
echo.
echo 🌐 Backend Connection:
echo • Android Emulator: https://10.0.2.2:44301
echo • iOS Simulator: https://localhost:44301
echo • Physical Device: Update IP in main.dart
echo.
echo ========================================
echo 🎯 HOW TO TEST:
echo ========================================
echo.
echo 1. MAKE SURE BACKEND IS RUNNING:
echo    - Your ASP.NET Core API should be running
echo    - Check: https://localhost:44301/api/TokenAuth/Authenticate
echo.
echo 2. CREATE USERS IN ADMIN PANEL:
echo    - Go to: http://localhost:4200/app/admin/users
echo    - Create new users with passwords
echo    - Note their usernames and passwords
echo.
echo 3. RUN FLUTTER APP:
echo    - Command: flutter run
echo    - Login with real user credentials
echo    - Check connection status
echo.
echo 4. TEST LOGIN:
echo    - Enter username and password
echo    - App will authenticate with backend
echo    - Success = Navigate to PTT screen
echo    - Failure = Show error message
echo.
echo Ready to test real authentication! 🚀
echo.
echo Commands:
echo   flutter devices    - Show available devices
echo   flutter run        - Run the app
echo   flutter run -v     - Run with verbose logging
echo.
pause
