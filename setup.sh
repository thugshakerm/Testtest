#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$ROOT/config.env"
APP="$ROOT/hexagon"
UPSTREAM="https://github.com/randomyaps/Hexagon.git"

fail() { echo "ERROR: $*" >&2; exit 1; }
command -v git >/dev/null || fail "git is required"
command -v docker >/dev/null || fail "Docker is required"
docker compose version >/dev/null 2>&1 || fail "Docker Compose v2 is required"

if [[ ! -f "$CONFIG" ]]; then
  cp "$ROOT/config.env.example" "$CONFIG"
  echo "Created config.env. Put your PostgreSQL password in it, then run this script again."
  exit 0
fi
# shellcheck disable=SC1090
source "$CONFIG"
: "${DB_PASSWORD:?Set DB_PASSWORD in config.env}"
[[ "$DB_PASSWORD" != "change-this-password" ]] || fail "Change DB_PASSWORD in config.env first"
SITE_DOMAIN="${SITE_DOMAIN:-localhost:9000}"
SKIP_BUILD="${SKIP_BUILD:-false}"

if [[ ! -d "$APP/.git" ]]; then
  echo "Cloning Hexagon..."
  git clone --depth 1 "$UPSTREAM" "$APP"
else
  echo "Hexagon already exists; leaving its source untouched. Use ./git-pull.sh to update it."
fi

# Generate secrets once. They are stored only in the ignored .env file.
random_secret() { (command -v openssl >/dev/null && openssl rand -hex 32) || od -An -N32 -tx1 /dev/urandom | tr -d ' \n'; }
if [[ ! -f "$APP/.env" ]]; then
  JWT="$(random_secret)"
  EVICT="$(random_secret)"
  CLIENT_KEY=""
  if command -v openssl >/dev/null 2>&1; then
    CLIENT_KEY="$(openssl genrsa 2048 2>/dev/null)"
  fi
  cat > "$APP/.env" <<EOF
DEBUG=false
DATABASE_URL=postgres://postgres:${DB_PASSWORD}@db:5432/postgres
DATABASE_LOGS=false
BASE_URL=${SITE_DOMAIN}
JWT_SECRET_KEY=${JWT}
EVICT_KEY=${EVICT}
DISCORD_CLIENT_ID=123
DISCORD_CLIENT_SECRET=
DISCORD_REDIRECT_URI=
DISCORD_LINKENABLED=false
DISCORD_WEBHOOK_STATS=
CLOUDFLARE_S3_ACCOUNT_ID=
CLOUDFLARE_S3_ACCESS_KEY_ID=
CLOUDFLARE_S3_ACCESS_KEY=
GAMESERVER_IP=
ARBITER_HOST=
RENDER_HOST=
RCC_ACCESS_KEY=
ASSET_ACCESS_KEY=
CLIENT_PRIVATE_KEY="${CLIENT_KEY}"
PUBLIC_setupcdn=${SITE_DOMAIN}
BODY_SIZE_LIMIT=Infinity
PUBLIC_ANALYTICS=false
PUBLIC_ANALYTICS_WEBSITEID=
PUBLIC_DISCORD_INVITE=
DISABLE_RENDER=true
EOF
  chmod 600 "$APP/.env"
fi

# A deliberately small stack: no unused analytics, backup, Ghost, Caddy, or
# Cloudflare containers. Cloudflare can proxy/tunnel to 127.0.0.1:9000.
cat > "$APP/compose.easy.yml" <<'EOF'
services:
  db:
    image: postgres:17-alpine
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_USER: postgres
      POSTGRES_DB: postgres
    volumes:
      - hexagon-db:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d postgres"]
      interval: 5s
      timeout: 5s
      retries: 20
  web:
    build: .
    restart: unless-stopped
    env_file: .env
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "127.0.0.1:9000:3000"
volumes:
  hexagon-db:
EOF
# Compose substitutes this value in compose.easy.yml.
if ! grep -q '^DB_PASSWORD=' "$APP/.env"; then printf '\nDB_PASSWORD=%s\n' "$DB_PASSWORD" >> "$APP/.env"; fi

cd "$APP"
if [[ "$SKIP_BUILD" == "true" ]]; then
  docker compose --env-file .env -f compose.easy.yml up -d
else
  docker compose --env-file .env -f compose.easy.yml up -d --build
fi

echo
echo "Hexagon is running at http://127.0.0.1:9000"
echo "Cloudflare Tunnel target: http://web:3000 (inside Compose) or http://127.0.0.1:9000 (host tunnel)"
echo "Update later with: cd '$ROOT' && ./git-pull.sh"
