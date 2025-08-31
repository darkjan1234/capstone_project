@echo off
echo ========================================
echo 🎙️ PTT VOICE TRANSMISSION SYSTEM
echo ========================================
echo.

echo This will start your Push-to-Talk voice system!
echo.
echo Features:
echo ✅ Real-time voice transmission over internet
echo ✅ Multiple users can connect
echo ✅ Push-to-talk functionality
echo ✅ Group communication
echo ✅ Web-based testing interface
echo.

set /p confirm="Start PTT Voice System? (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Step 1: Building the project...
cd "Aspdotnet-zero-dual-solution\aspnet-core\src\Business.Solutions.Web.Host"

dotnet build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Build successful!
    echo.
    echo Step 2: Starting PTT Voice Server...
    echo.
    echo 🌐 Server will start on: https://localhost:44301
    echo 🎙️ PTT Test Page: https://localhost:44301/ptt-test.html
    echo 📡 SignalR Hub: https://localhost:44301/signalr-ptt-voice
    echo.
    echo ========================================
    echo 🎯 HOW TO TEST PTT VOICE SYSTEM:
    echo ========================================
    echo.
    echo 1. Open browser: https://localhost:44301/ptt-test.html
    echo 2. Click "Connect User 1" button
    echo 3. Click "Connect User 2" button  
    echo 4. Click "Connect User 3" button
    echo.
    echo 5. Hold down "PUSH TO TALK" button on User 1
    echo 6. Speak into microphone
    echo 7. Release button
    echo 8. Other users should hear the audio!
    echo.
    echo 🔊 Make sure:
    echo - Allow microphone access when prompted
    echo - Use headphones to avoid feedback
    echo - Test with different browser tabs/windows
    echo.
    echo Press Ctrl+C to stop the server when done.
    echo.
    
    dotnet run
    
) else (
    echo.
    echo ❌ Build failed!
    echo.
    echo Possible issues:
    echo 1. Missing SignalR references
    echo 2. Compilation errors
    echo 3. Missing dependencies
    echo.
    echo Solutions:
    echo 1. Run: dotnet restore
    echo 2. Check error messages above
    echo 3. Make sure all files are saved
    echo.
)

echo.
echo ========================================
echo 🎙️ PTT Voice System Stopped
echo ========================================
pause
