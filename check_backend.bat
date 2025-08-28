@echo off
echo ========================================
echo Checking Backend Server
echo ========================================
echo.

cd "Aspdotnet-zero-dual-solution\aspnet-core"

echo Step 1: Building the project...
dotnet build

echo.
echo Step 2: If build succeeded, starting the server...
echo Press Ctrl+C to stop the server when it's running
echo.
dotnet run --project "src\Business.Solutions.Web.Host\Business.Solutions.Web.Host.csproj"

pause
