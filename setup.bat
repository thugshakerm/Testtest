@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

rem Native Windows installer: Docker is intentionally not used.
if not exist config.env (
  copy /y config.env.example config.env >nul
  echo Created config.env. Edit DB_PASSWORD, then run setup.bat again.
  notepad config.env
  pause
  exit /b 0
)
for /f "usebackq tokens=1,* delims==" %%A in ("config.env") do if "%%A"=="DB_PASSWORD" set "DB_PASSWORD=%%B"
for /f "usebackq tokens=1,* delims==" %%A in ("config.env") do if "%%A"=="SITE_DOMAIN" set "SITE_DOMAIN=%%B"
if "%DB_PASSWORD%"=="" (echo DB_PASSWORD is missing from config.env& pause& exit /b 1)
if "%DB_PASSWORD%"=="change-this-password" (echo Change DB_PASSWORD in config.env first& pause& exit /b 1)
if "%SITE_DOMAIN%"=="" set "SITE_DOMAIN=localhost:9000"
for /f "usebackq tokens=1,* delims==" %%A in ("config.env") do if "%%A"=="DB_PORT" set "DB_PORT=%%B"
if "%DB_PORT%"=="" set "DB_PORT=5434"

where node >nul 2>&1 || (
  echo Node.js is required. Install it with:
  echo winget install OpenJS.NodeJS.LTS
  pause
  exit /b 1
)
where npm >nul 2>&1 || (echo npm was not found. Restart PowerShell after installing Node.js.& pause& exit /b 1)
where psql >nul 2>&1 || (
  echo PostgreSQL is required because this installer does not use Docker.
  echo Install PostgreSQL 17 with:
  echo winget install PostgreSQL.PostgreSQL.17
  echo During installation, use the same DB_PASSWORD from config.env for the postgres user.
  pause
  exit /b 1
)

if not exist hexagon\.git (
  echo Cloning Hexagon...
  git clone --depth 1 https://github.com/randomyaps/Hexagon.git hexagon || exit /b 1
)
if not exist hexagon\.env (
  for /f %%A in ('powershell -NoProfile -Command "[guid]::NewGuid().ToString('N')"') do set JWT=%%A
  for /f %%A in ('powershell -NoProfile -Command "[guid]::NewGuid().ToString('N')"') do set EVICT=%%A
  >hexagon\.env echo DEBUG=false
  >>hexagon\.env echo DATABASE_URL=postgres://postgres:%DB_PASSWORD%@localhost:%DB_PORT%/postgres
  >>hexagon\.env echo DATABASE_LOGS=false
  >>hexagon\.env echo BASE_URL=%SITE_DOMAIN%
  >>hexagon\.env echo JWT_SECRET_KEY=!JWT!
  >>hexagon\.env echo EVICT_KEY=!EVICT!
  >>hexagon\.env echo DISCORD_CLIENT_ID=123
  >>hexagon\.env echo DISCORD_CLIENT_SECRET=
  >>hexagon\.env echo DISCORD_REDIRECT_URI=
  >>hexagon\.env echo DISCORD_LINKENABLED=false
  >>hexagon\.env echo GAMESERVER_IP=
  >>hexagon\.env echo ARBITER_HOST=
  >>hexagon\.env echo RENDER_HOST=
  >>hexagon\.env echo CLIENT_PRIVATE_KEY=
  >>hexagon\.env echo PUBLIC_setupcdn=%SITE_DOMAIN%
  >>hexagon\.env echo BODY_SIZE_LIMIT=Infinity
  >>hexagon\.env echo DISABLE_RENDER=true
)

rem Configure free local S3-compatible storage instead of paid Cloudflare R2.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0enable-local-s3.ps1" || exit /b 1

rem Find and start the PostgreSQL Windows service if it is stopped.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Service -Name 'postgresql*' -ErrorAction SilentlyContinue ^| Where-Object Status -ne 'Running' ^| Start-Service" >nul 2>&1
set PGPASSWORD=%DB_PASSWORD%
psql -h localhost -p %DB_PORT% -U postgres -d postgres -c "SELECT 1" >nul 2>&1 || (
  echo Could not connect to PostgreSQL.
  echo Make sure PostgreSQL is running and its postgres-user password matches config.env.
  pause
  exit /b 1
)

cd hexagon
if not exist node_modules (
  echo Installing Node dependencies...
  call npm install || exit /b 1
)
rem Upstream uses Svelte 4; pin Superforms before building because newer releases use Svelte 5 runes.
call npm install --save-exact sveltekit-superforms@2.12.4 || exit /b 1
echo Building Hexagon...
call npm run build || exit /b 1
echo Applying database schema...
call npm run push || exit /b 1
echo Starting Hexagon...
start "Hexagon" /b cmd /c "npm run prod > hexagon.log 2>&1"
echo.
echo Hexagon is running at http://127.0.0.1:9000
echo Logs: %CD%\hexagon.log
echo Cloudflare Tunnel target: http://127.0.0.1:9000
pause
