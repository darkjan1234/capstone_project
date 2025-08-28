@echo off
echo ========================================
echo Fixing PTT Groups Migration
echo ========================================
echo.

cd "Aspdotnet-zero-dual-solution\aspnet-core"

echo Step 1: Removing failed migration...
dotnet ef migrations remove --project "src\Business.Solutions.EntityFrameworkCore\Business.Solutions.EntityFrameworkCore.csproj" --startup-project "src\Business.Solutions.Web.Host\Business.Solutions.Web.Host.csproj" --force
if %errorlevel% neq 0 (
    echo Warning: Could not remove migration (might not exist)
)

echo.
echo Step 2: Creating new migration with fixed constraints...
dotnet ef migrations add AddPttGroupTablesFixed --project "src\Business.Solutions.EntityFrameworkCore\Business.Solutions.EntityFrameworkCore.csproj" --startup-project "src\Business.Solutions.Web.Host\Business.Solutions.Web.Host.csproj"
if %errorlevel% neq 0 (
    echo ERROR: Migration creation failed!
    pause
    exit /b 1
)

echo.
echo Step 3: Updating database...
dotnet ef database update --project "src\Business.Solutions.EntityFrameworkCore\Business.Solutions.EntityFrameworkCore.csproj" --startup-project "src\Business.Solutions.Web.Host\Business.Solutions.Web.Host.csproj"
if %errorlevel% neq 0 (
    echo ERROR: Database update failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ Migration Fixed Successfully!
echo ========================================
echo.
echo The PTT Groups tables have been created with proper foreign key constraints.
echo You can now run the backend and start using the PTT Group Management system.
echo.
pause
