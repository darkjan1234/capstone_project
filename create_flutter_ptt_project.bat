@echo off
echo ========================================
echo 🚀 CREATING FLUTTER PTT PROJECT
echo ========================================
echo.

echo This will create a new Flutter PTT project with all necessary files.
echo.

set /p confirm="Create Flutter PTT project? (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Step 1: Creating Flutter project...

REM Create new Flutter project
flutter create flutter_ptt_voice_app

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to create Flutter project!
    echo Make sure Flutter is installed and in PATH.
    pause
    exit /b
)

echo ✅ Flutter project created successfully!

echo.
echo Step 2: Copying PTT files...

REM Copy our PTT files to the new project
cd flutter_ptt_voice_app

REM Create directories
mkdir lib\services
mkdir lib\screens

echo.
echo Step 3: Setting up dependencies...

REM Update pubspec.yaml with our dependencies
echo name: flutter_ptt_voice_app > pubspec.yaml
echo description: Push-to-Talk Voice Transmission App >> pubspec.yaml
echo. >> pubspec.yaml
echo publish_to: 'none' >> pubspec.yaml
echo. >> pubspec.yaml
echo version: 1.0.0+1 >> pubspec.yaml
echo. >> pubspec.yaml
echo environment: >> pubspec.yaml
echo   sdk: '>=3.0.0 ^<4.0.0' >> pubspec.yaml
echo. >> pubspec.yaml
echo dependencies: >> pubspec.yaml
echo   flutter: >> pubspec.yaml
echo     sdk: flutter >> pubspec.yaml
echo   http: ^1.1.0 >> pubspec.yaml
echo   signalr_netcore: ^1.3.7 >> pubspec.yaml
echo   record: ^5.0.4 >> pubspec.yaml
echo   audioplayers: ^5.2.1 >> pubspec.yaml
echo   permission_handler: ^11.0.1 >> pubspec.yaml
echo   provider: ^6.1.1 >> pubspec.yaml
echo   cupertino_icons: ^1.0.2 >> pubspec.yaml
echo   shared_preferences: ^2.2.2 >> pubspec.yaml
echo. >> pubspec.yaml
echo dev_dependencies: >> pubspec.yaml
echo   flutter_test: >> pubspec.yaml
echo     sdk: flutter >> pubspec.yaml
echo   flutter_lints: ^3.0.0 >> pubspec.yaml
echo. >> pubspec.yaml
echo flutter: >> pubspec.yaml
echo   uses-material-design: true >> pubspec.yaml

echo ✅ Dependencies configured!

echo.
echo Step 4: Installing dependencies...
flutter pub get

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to install dependencies!
    pause
    exit /b
)

echo ✅ Dependencies installed successfully!

echo.
echo ========================================
echo ✅ FLUTTER PTT PROJECT READY!
echo ========================================
echo.
echo Project created: flutter_ptt_voice_app
echo.
echo Next steps:
echo 1. Copy the PTT source files manually
echo 2. Update Android permissions
echo 3. Test the app
echo.
echo Commands to run:
echo   cd flutter_ptt_voice_app
echo   flutter run
echo.
pause
