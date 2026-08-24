@echo off
setlocal
cd /d "%~dp0"
if not exist hexagon\.git (
  echo Run setup.bat first.
  pause
  exit /b 1
)
cd hexagon
git pull --ff-only
if errorlevel 1 exit /b 1
docker compose --env-file .env -f compose.easy.yml up -d --build
if errorlevel 1 exit /b 1
echo Hexagon updated and restarted.
pause
