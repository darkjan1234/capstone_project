@echo off
echo ========================================
echo Restarting Angular Development Server
echo ========================================
echo.

cd "Aspdotnet-zero-dual-solution\angular"

echo Step 1: Stopping any running Angular processes...
taskkill /f /im node.exe 2>nul
timeout /t 2 /nobreak >nul

echo.
echo Step 2: Clearing Angular cache...
if exist "node_modules\.angular" (
    rmdir /s /q "node_modules\.angular"
    echo Angular cache cleared
)

echo.
echo Step 3: Starting Angular development server...
echo This will open in your browser automatically
echo Press Ctrl+C to stop the server when needed
echo.

start /b ng serve --open

echo.
echo ========================================
echo ✅ Angular server is starting...
echo ========================================
echo.
echo The app should open in your browser at: http://localhost:4200
echo.
echo If you see compilation errors:
echo 1. Check the terminal output above
echo 2. The PTT Groups module has been temporarily disabled
echo 3. The main app should work normally
echo.
echo To re-enable PTT Groups later:
echo 1. Fix all Angular component errors
echo 2. Uncomment the route in admin-routing.module.ts
echo 3. Restart Angular
echo.
pause
