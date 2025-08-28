@echo off
echo ========================================
echo Simple PTT Groups Fix
echo ========================================
echo.

cd "Aspdotnet-zero-dual-solution\aspnet-core"

echo Step 1: Removing any failed migration...
dotnet ef migrations remove --force --project "src\Business.Solutions.EntityFrameworkCore\Business.Solutions.EntityFrameworkCore.csproj" --startup-project "src\Business.Solutions.Web.Host\Business.Solutions.Web.Host.csproj"

echo.
echo Step 2: Creating new migration...
dotnet ef migrations add AddPttGroupsFixed --project "src\Business.Solutions.EntityFrameworkCore\Business.Solutions.EntityFrameworkCore.csproj" --startup-project "src\Business.Solutions.Web.Host\Business.Solutions.Web.Host.csproj"

echo.
echo Step 3: Updating database...
dotnet ef database update --project "src\Business.Solutions.EntityFrameworkCore\Business.Solutions.EntityFrameworkCore.csproj" --startup-project "src\Business.Solutions.Web.Host\Business.Solutions.Web.Host.csproj"

echo.
echo ========================================
echo Done! Check if it worked above.
echo ========================================
pause
