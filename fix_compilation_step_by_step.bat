@echo off
echo ========================================
echo Step-by-Step PTT System Fix
echo ========================================
echo.

echo This will fix the compilation issues step by step:
echo.
echo Step 1: Build basic system without regional properties
echo Step 2: Add database columns manually
echo Step 3: Rebuild with regional properties
echo Step 4: Test regional security
echo.

set /p confirm="Continue with Step 1? (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo ========================================
echo Step 1: Building Basic System
echo ========================================
echo.

cd "Aspdotnet-zero-dual-solution\aspnet-core\src\Business.Solutions.Web.Host"

echo Building project...
dotnet build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Step 1 Complete: Basic system builds successfully!
    echo.
    echo ========================================
    echo Step 2: Add Database Columns
    echo ========================================
    echo.
    echo Now run this command to add regional columns:
    echo.
    echo   update_database_for_regions.bat
    echo.
    echo After database update:
    echo 1. The RegionCode and PttRole columns will exist in database
    echo 2. The Entity Framework will recognize the properties
    echo 3. Regional security will work
    echo.
    echo ========================================
    echo Step 3: Test Basic API
    echo ========================================
    echo.
    echo Start the API to test basic functionality:
    echo.
    echo   dotnet run
    echo.
    echo Test endpoints:
    echo   GET /api/PttTest/check-database
    echo   GET /api/PttTest/current-user-info
    echo   GET /api/PttTest/accessible-groups
    echo.
) else (
    echo.
    echo ❌ Step 1 Failed: Build errors detected
    echo.
    echo Check the error messages above.
    echo Most likely issues:
    echo 1. Missing references
    echo 2. Syntax errors
    echo 3. Namespace issues
    echo.
    echo Fix these errors first, then run this script again.
)

echo.
pause
