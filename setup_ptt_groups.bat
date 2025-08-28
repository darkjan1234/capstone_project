@echo off
echo ========================================
echo PTT Group Management System Setup
echo ========================================
echo.

echo Step 1: Building the backend...
cd "Aspdotnet-zero-dual-solution\aspnet-core"
dotnet build
if %errorlevel% neq 0 (
    echo ERROR: Backend build failed!
    pause
    exit /b 1
)

echo.
echo Step 2: Adding database migration...
dotnet ef migrations add AddPttGroupTables -p src\Business.Solutions.EntityFrameworkCore -s src\Business.Solutions.Web.Host
if %errorlevel% neq 0 (
    echo ERROR: Migration creation failed!
    pause
    exit /b 1
)

echo.
echo Step 3: Updating database...
dotnet ef database update -p src\Business.Solutions.EntityFrameworkCore -s src\Business.Solutions.Web.Host
if %errorlevel% neq 0 (
    echo ERROR: Database update failed!
    pause
    exit /b 1
)

echo.
echo Step 4: Setting up Angular...
cd "..\angular"
echo Installing Angular dependencies...
call npm install
if %errorlevel% neq 0 (
    echo ERROR: Angular npm install failed!
    pause
    exit /b 1
)

echo.
echo Step 5: Setting up Flutter...
cd "..\my_api_app"
echo Getting Flutter dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ PTT Group Management System Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Start the backend: cd Aspdotnet-zero-dual-solution\aspnet-core && dotnet run --project src\Business.Solutions.Web.Host
echo 2. Start Angular: cd Aspdotnet-zero-dual-solution\angular && ng serve
echo 3. Start Flutter: cd my_api_app && flutter run
echo.
echo Features available:
echo - ✅ Hierarchical PTT Group Management
echo - ✅ Admin-controlled user groups
echo - ✅ Visual group hierarchy tree
echo - ✅ Role-based access control
echo - ✅ Real-time PTT communication
echo.
pause
