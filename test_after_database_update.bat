@echo off
echo ========================================
echo Testing After Database Update
echo ========================================
echo.

echo This script will:
echo 1. Rebuild the project with regional properties
echo 2. Start the API server
echo 3. Test the regional security endpoints
echo.

set /p confirm="Continue? (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Step 1: Rebuilding project...
cd "Aspdotnet-zero-dual-solution\aspnet-core\src\Business.Solutions.Web.Host"

dotnet clean
dotnet build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Build successful!
    echo.
    echo Step 2: Starting API server...
    echo.
    echo The API will start on https://localhost:44301
    echo.
    echo Test these endpoints in your browser or Postman:
    echo.
    echo Basic Tests:
    echo   GET https://localhost:44301/api/PttTest/check-database
    echo   GET https://localhost:44301/api/PttTest/current-user-info
    echo   GET https://localhost:44301/api/PttTest/accessible-groups
    echo.
    echo Regional Security Tests (after login):
    echo   GET https://localhost:44301/api/PttTest/can-communicate/2
    echo.
    echo Swagger Documentation:
    echo   https://localhost:44301/swagger
    echo.
    echo Press Ctrl+C to stop the server when done testing.
    echo.
    
    dotnet run
    
) else (
    echo.
    echo ❌ Build failed!
    echo.
    echo Possible issues:
    echo 1. Database columns not added yet
    echo 2. Entity Framework cache needs clearing
    echo 3. Compilation errors still exist
    echo.
    echo Solutions:
    echo 1. Make sure you ran: update_database_for_regions.bat
    echo 2. Try: dotnet clean && dotnet build
    echo 3. Check error messages above
    echo.
)

pause
