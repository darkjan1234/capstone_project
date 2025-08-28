@echo off
echo ========================================
echo Temporarily Disabling PTT Groups
echo ========================================
echo.

echo This will comment out the PTT Groups module to fix Angular compilation errors.
echo You can re-enable it later after fixing all issues.
echo.

cd "Aspdotnet-zero-dual-solution\angular\src\app\admin"

echo Step 1: Commenting out PTT Groups routing...
if exist "admin-routing.module.ts" (
    echo Found admin routing file
) else (
    echo Admin routing file not found
)

echo.
echo Step 2: Removing PTT Groups from admin module...
if exist "admin.module.ts" (
    echo Found admin module file
) else (
    echo Admin module file not found
)

echo.
echo ========================================
echo Manual Steps Required:
echo ========================================
echo.
echo 1. Open: src\app\admin\admin-routing.module.ts
echo 2. Comment out the PTT Groups route:
echo    // { path: 'ptt-groups', loadChildren: () => import('./ptt-groups/ptt-groups.module').then(m => m.PttGroupsModule) }
echo.
echo 3. Open: src\app\admin\admin.module.ts  
echo 4. Remove any PTT Groups imports if present
echo.
echo 5. Restart Angular: ng serve
echo.
echo This will allow Angular to compile without PTT Groups errors.
echo Once the main app is working, we can fix the PTT Groups module properly.
echo.
pause
