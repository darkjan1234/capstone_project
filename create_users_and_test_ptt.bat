@echo off
echo ========================================
echo 🎙️ CREATE USERS AND TEST PTT SYSTEM
echo ========================================
echo.

echo This will:
echo 1. Add database columns for regional security
echo 2. Create test users for PTT
echo 3. Start the PTT voice system
echo 4. Open test page for voice transmission
echo.

set /p confirm="Continue? (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo ========================================
echo Step 1: Adding Database Columns
echo ========================================

sqlcmd -S "(localdb)\MSSQLLocalDB" -d "SolutionsDb" -i "add_region_columns.sql"

if %ERRORLEVEL% EQU 0 (
    echo ✅ Database columns added successfully!
) else (
    echo ⚠️  Database update may have failed, but continuing...
)

echo.
echo ========================================
echo Step 2: Creating Test Users
echo ========================================

sqlcmd -S "(localdb)\MSSQLLocalDB" -d "SolutionsDb" -i "create_ptt_test_users.sql"

if %ERRORLEVEL% EQU 0 (
    echo ✅ Test users created successfully!
) else (
    echo ⚠️  User creation may have failed, but continuing...
)

echo.
echo ========================================
echo Step 3: Starting PTT Voice System
echo ========================================

cd "Aspdotnet-zero-dual-solution\aspnet-core\src\Business.Solutions.Web.Host"

echo Building project...
dotnet build

if %ERRORLEVEL% EQU 0 (
    echo ✅ Build successful!
    echo.
    echo ========================================
    echo 🎯 PTT VOICE SYSTEM READY!
    echo ========================================
    echo.
    echo 👥 Test Users Created:
    echo   1. admin / 123qwe (Super Admin)
    echo   2. john / 123qwe (Field User)
    echo   3. user / 123qwe (Field User)
    echo.
    echo 🌐 Server starting on: https://localhost:44301
    echo 🎙️ PTT Test Page: https://localhost:44301/ptt-test.html
    echo.
    echo ========================================
    echo 🎯 HOW TO TEST VOICE TRANSMISSION:
    echo ========================================
    echo.
    echo 1. Server will start automatically
    echo 2. Browser will open test page
    echo 3. Click "Connect User 1" (admin)
    echo 4. Click "Connect User 2" (john)  
    echo 5. Click "Connect User 3" (user)
    echo 6. Hold "PUSH TO TALK" and speak
    echo 7. Other users should hear your voice!
    echo.
    echo 🔊 Important:
    echo - Allow microphone access when prompted
    echo - Use headphones to avoid feedback
    echo - Test in different browser tabs
    echo.
    echo Starting server and opening test page...
    echo Press Ctrl+C to stop when done testing.
    echo.
    
    timeout /t 3 /nobreak >nul
    
    REM Start the server in background and open browser
    start "" "https://localhost:44301/ptt-test.html"
    
    dotnet run
    
) else (
    echo.
    echo ❌ Build failed!
    echo.
    echo Check the error messages above and fix any issues.
    echo Then try running: start_ptt_voice_system.bat
    echo.
)

echo.
echo ========================================
echo 🎙️ PTT Voice System Stopped
echo ========================================
echo.
echo If you want to test again:
echo 1. Run: start_ptt_voice_system.bat
echo 2. Go to: https://localhost:44301/ptt-test.html
echo 3. Connect users and test voice transmission
echo.
pause
