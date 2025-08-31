@echo off
echo ========================================
echo 🧪 TESTING BACKEND AUTHENTICATION
echo ========================================
echo.

echo This will test if your backend authentication is working properly.
echo.

set /p confirm="Test backend authentication? (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Step 1: Testing backend connection...

curl -X GET "https://localhost:44301/api/PttTest/check-database" -H "Content-Type: application/json" -k

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Backend is reachable
) else (
    echo.
    echo ❌ Backend connection failed!
    echo Make sure your ASP.NET Core API is running on https://localhost:44301
    pause
    exit /b
)

echo.
echo Step 2: Testing authentication endpoint...

curl -X POST "https://localhost:44301/api/TokenAuth/Authenticate" ^
     -H "Content-Type: application/json" ^
     -H "Accept: application/json" ^
     -k ^
     -d "{\"userNameOrEmailAddress\":\"admin\",\"password\":\"123qwe\",\"rememberClient\":true}"

echo.
echo.
echo Step 3: Testing with different user...

curl -X POST "https://localhost:44301/api/TokenAuth/Authenticate" ^
     -H "Content-Type: application/json" ^
     -H "Accept: application/json" ^
     -k ^
     -d "{\"userNameOrEmailAddress\":\"john\",\"password\":\"123qwe\",\"rememberClient\":true}"

echo.
echo.
echo ========================================
echo 📋 AUTHENTICATION TEST RESULTS
echo ========================================
echo.
echo If you see JSON responses with "success": true, authentication is working!
echo.
echo Expected response format:
echo {
echo   "result": {
echo     "accessToken": "...",
echo     "userId": 1,
echo     "userName": "admin",
echo     "name": "admin"
echo   },
echo   "success": true
echo }
echo.
echo If you see errors:
echo 1. Make sure backend is running: dotnet run
echo 2. Check if users exist in database
echo 3. Verify passwords are correct
echo 4. Check SSL certificate issues
echo.
echo ========================================
echo 🎯 NEXT STEPS:
echo ========================================
echo.
echo 1. If authentication works:
echo    - Run: update_flutter_with_real_auth.bat
echo    - Then: flutter run
echo    - Test login in mobile app
echo.
echo 2. If authentication fails:
echo    - Check backend logs
echo    - Verify user accounts exist
echo    - Check database connection
echo.
echo 3. Create more users:
echo    - Go to: http://localhost:4200/app/admin/users
echo    - Create users with passwords
echo    - Test login with those credentials
echo.
pause
