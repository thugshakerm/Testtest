@echo off
setlocal
cd /d "%~dp0"
if not exist hexagon\.git (
  echo Run setup.bat first.
  pause
  exit /b 1
)
where node >nul 2>&1 || (echo Node.js is required.& pause& exit /b 1)
where npm >nul 2>&1 || (echo npm was not found. Restart PowerShell.& pause& exit /b 1)
cd hexagon
git pull --ff-only
if errorlevel 1 exit /b 1
call npm install
if errorlevel 1 exit /b 1
rem Keep dependencies compatible with Hexagon's Svelte 4 stack.
call npm install --save-exact sveltekit-superforms@2.12.4
if errorlevel 1 exit /b 1
call npm run build
if errorlevel 1 exit /b 1
call npm run push
if errorlevel 1 exit /b 1
for /f "tokens=2" %%A in ('tasklist /fi "WINDOWTITLE eq Hexagon" /fo list ^| findstr /i "PID"') do taskkill /PID %%A /F >nul 2>&1
start "Hexagon" /b cmd /c "npm run prod > hexagon.log 2>&1"
echo Hexagon updated and restarted.
pause
