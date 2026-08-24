@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
if not exist config.env (
  copy /y config.env.example config.env >nul
  echo Created config.env. Edit DB_PASSWORD, then run setup.bat again.
  pause
  exit /b 0
)
for /f "usebackq tokens=1,* delims==" %%A in ("config.env") do if "%%A"=="DB_PASSWORD" set "DB_PASSWORD=%%B"
for /f "usebackq tokens=1,* delims==" %%A in ("config.env") do if "%%A"=="SITE_DOMAIN" set "SITE_DOMAIN=%%B"
if "%DB_PASSWORD%"=="" echo DB_PASSWORD is missing from config.env & pause & exit /b 1
if "%DB_PASSWORD%"=="change-this-password" echo Change DB_PASSWORD in config.env first & pause & exit /b 1
if "%SITE_DOMAIN%"=="" set "SITE_DOMAIN=localhost:9000"
where git >nul 2>&1 || (echo Git is required.& pause& exit /b 1)
where docker >nul 2>&1 || (echo Docker Desktop is required.& pause& exit /b 1)
docker info >nul 2>&1 || (
  echo Docker is installed, but the Docker engine is not running.
  echo Start Docker Desktop and fix its virtualization error before retrying.
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
  >>hexagon\.env echo DATABASE_URL=postgres://postgres:%DB_PASSWORD%@db:5432/postgres
  >>hexagon\.env echo DATABASE_LOGS=false
  >>hexagon\.env echo BASE_URL=%SITE_DOMAIN%
  >>hexagon\.env echo JWT_SECRET_KEY=!JWT!
  >>hexagon\.env echo EVICT_KEY=!EVICT!
  >>hexagon\.env echo DISCORD_LINKENABLED=false
  >>hexagon\.env echo DISABLE_RENDER=true
  >>hexagon\.env echo PUBLIC_setupcdn=%SITE_DOMAIN%
  >>hexagon\.env echo BODY_SIZE_LIMIT=Infinity
  >>hexagon\.env echo DB_PASSWORD=%DB_PASSWORD%
)
>hexagon\compose.easy.yml echo services:
>>hexagon\compose.easy.yml echo   db:
>>hexagon\compose.easy.yml echo     image: postgres:17-alpine
>>hexagon\compose.easy.yml echo     restart: unless-stopped
>>hexagon\compose.easy.yml echo     environment:
>>hexagon\compose.easy.yml echo       POSTGRES_PASSWORD: ${DB_PASSWORD}
>>hexagon\compose.easy.yml echo       POSTGRES_USER: postgres
>>hexagon\compose.easy.yml echo       POSTGRES_DB: postgres
>>hexagon\compose.easy.yml echo     volumes:
>>hexagon\compose.easy.yml echo       - hexagon-db:/var/lib/postgresql/data
>>hexagon\compose.easy.yml echo     healthcheck:
>>hexagon\compose.easy.yml echo       test: ["CMD-SHELL", "pg_isready -U postgres -d postgres"]
>>hexagon\compose.easy.yml echo       interval: 5s
>>hexagon\compose.easy.yml echo       timeout: 5s
>>hexagon\compose.easy.yml echo       retries: 20
>>hexagon\compose.easy.yml echo   web:
>>hexagon\compose.easy.yml echo     build: .
>>hexagon\compose.easy.yml echo     restart: unless-stopped
>>hexagon\compose.easy.yml echo     env_file: .env
>>hexagon\compose.easy.yml echo     depends_on:
>>hexagon\compose.easy.yml echo       db:
>>hexagon\compose.easy.yml echo         condition: service_healthy
>>hexagon\compose.easy.yml echo     ports:
>>hexagon\compose.easy.yml echo       - "127.0.0.1:9000:3000"
>>hexagon\compose.easy.yml echo volumes:
>>hexagon\compose.easy.yml echo   hexagon-db:
cd hexagon
docker compose --env-file .env -f compose.easy.yml up -d --build
if errorlevel 1 exit /b 1
echo Hexagon is running at http://127.0.0.1:9000
pause
