@echo off
echo ========================================
echo Creating PTT Region Migration
echo ========================================
echo.

cd "Aspdotnet-zero-dual-solution\aspnet-core\src\Business.Solutions.EntityFrameworkCore"

echo Step 1: Creating migration for PTT Region support...
dotnet ef migrations add "Add_PTT_Region_Support" --startup-project ..\Business.Solutions.Web.Host\Business.Solutions.Web.Host.csproj

echo.
echo Step 2: Updating database...
dotnet ef database update --startup-project ..\Business.Solutions.Web.Host\Business.Solutions.Web.Host.csproj

echo.
echo ========================================
echo ✅ Migration completed!
echo ========================================
echo.
echo New features added:
echo - RegionCode property to PttGroup
echo - RegionCode property to User
echo - PttRole property to User
echo - Communication security methods
echo.
echo This enables:
echo ✅ PPO-based regional isolation
echo ✅ Secure communication within regions only
echo ✅ Admin hierarchy (Super Admin → PPO Admin → Users)
echo ✅ Role-based access control
echo.
pause
