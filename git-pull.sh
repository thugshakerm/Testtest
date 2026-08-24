#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$ROOT/hexagon"
[[ -d "$APP/.git" ]] || { echo "Hexagon is not installed. Run ./setup.sh first." >&2; exit 1; }
command -v docker >/dev/null || { echo "Docker is required." >&2; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "Docker Compose v2 is required." >&2; exit 1; }
cd "$APP"
git pull --ff-only
# Keep the generated easy compose file and local .env; upstream updates the app source.
docker compose --env-file .env -f compose.easy.yml up -d --build
echo "Hexagon updated and restarted."
