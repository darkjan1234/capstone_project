@echo off
echo ========================================
echo Testing PTT Regional Security Compilation
echo ========================================
echo.

cd "Aspdotnet-zero-dual-solution\aspnet-core\src\Business.Solutions.Web.Host"

echo Step 1: Building the project...
dotnet build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Compilation successful!
    echo.
    echo Step 2: Testing database update...
    echo Run this command to add regional columns:
    echo.
    echo   update_database_for_regions.bat
    echo.
    echo Step 3: After database update, test the API:
    echo.
    echo   dotnet run
    echo.
    echo Then test these endpoints:
    echo   GET /api/PttTest/check-database
    echo   GET /api/PttTest/current-user-info
    echo   GET /api/PttTest/accessible-groups
    echo   GET /api/PttTest/can-communicate/2
    echo.
) else (
    echo.
    echo ❌ Compilation failed!
    echo.
    echo Check the error messages above and fix any remaining issues.
    echo.
    echo Common fixes:
    echo 1. Make sure all using directives are correct
    echo 2. Check that PttGroup and User entities are accessible
    echo 3. Verify namespace references
    echo.
)

pause
