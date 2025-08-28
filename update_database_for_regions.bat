@echo off
echo ========================================
echo Adding PPO Regional Support to Database
echo ========================================
echo.

echo This will add RegionCode and PttRole columns to your database
echo and create sample PPO regions for testing.
echo.

set /p confirm="Do you want to continue? (Y/N): "
if /i "%confirm%" NEQ "Y" (
    echo Operation cancelled.
    pause
    exit /b
)

echo.
echo Step 1: Checking database connection...

cd "Aspdotnet-zero-dual-solution\aspnet-core\src\Business.Solutions.Web.Host"

echo.
echo Step 2: Running SQL script to add regional support...

sqlcmd -S "(localdb)\MSSQLLocalDB" -d "SolutionsDb" -i "..\..\..\..\add_region_columns.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo ✅ Database updated successfully!
    echo ========================================
    echo.
    echo New features added:
    echo ✅ RegionCode column in Users table
    echo ✅ PttRole column in Users table  
    echo ✅ RegionCode column in PttGroups table
    echo ✅ Sample PPO regions created
    echo.
    echo Sample regions created:
    echo - PPO Region 1 (REGION1)
    echo - PPO Region 2 (REGION2)  
    echo - PPO Bohol (BOHOL)
    echo - PPO Cebu (CEBU)
    echo.
    echo Next steps:
    echo 1. Restart your backend API
    echo 2. Test user creation with regions
    echo 3. Implement Flutter regional login
    echo.
) else (
    echo.
    echo ❌ Error updating database!
    echo.
    echo Possible solutions:
    echo 1. Make sure SQL Server is running
    echo 2. Check database connection string
    echo 3. Run the SQL script manually in SSMS
    echo.
    echo Manual SQL file location: add_region_columns.sql
    echo.
)

pause
