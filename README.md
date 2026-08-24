# Easy Hexagon setup

This small wrapper makes the public [Hexagon](https://github.com/randomyaps/Hexagon) source easier to install. It does not redistribute Hexagon; the setup script clones it from GitHub.

> **Important:** Hexagon's upstream README says not to publicly re-host it and notes that its arbiter is not included. Review the source and its license/permissions before exposing it through Cloudflare. The simplified stack starts the web app and PostgreSQL only; game launching/rendering will need the missing services configured separately.

## Windows without Docker

`setup.bat` now runs natively and does not use Docker. It requires Node.js and PostgreSQL. If they are missing, install them with PowerShell:

```powershell
winget install OpenJS.NodeJS.LTS
winget install PostgreSQL.PostgreSQL.17
```

During PostgreSQL installation, use the same password that will be placed in `config.env` for the `postgres` user. Then run:

```powershell
git clone --branch arena/01a03554-testtest https://github.com/thugshakerm/Testtest.git C:\\hexagon-installer
Set-Location C:\\hexagon-installer
Copy-Item config.env.example config.env
notepad config.env
.\\setup.bat
```

The native installer installs dependencies, builds Hexagon, applies the database schema, and starts Node on `127.0.0.1:9000`.

## VPS (Linux)

```bash
git clone https://github.com/thugshakerm/Testtest.git hexagon-installer
cd hexagon-installer
nano config.env                 # set DB_PASSWORD; SITE_DOMAIN is optional
chmod +x setup.sh git-pull.sh
./setup.sh
```

The Linux script uses Docker and is intended for a Linux host with Docker available. For Windows without virtualization, use `setup.bat` above.

The app is bound to `127.0.0.1:9000`, which is appropriate for a Cloudflare Tunnel/route on the same machine. The setup script creates `hexagon/.env`, generates local secrets, runs migrations, and starts the app.

To update later:

```bash
./git-pull.sh
```

## Configuration

Copy `config.env.example` to `config.env`. The only required secret is `DB_PASSWORD`. Set `SITE_DOMAIN` to the hostname used by Cloudflare if you want generated legacy game URLs to use that hostname; otherwise it defaults to `localhost:9000` for local testing.

Never commit `config.env`.

## Windows

`setup.bat` and `git-pull.bat` are included for a Windows machine with Docker Desktop and Git. A normal Linux VPS should use the `.sh` files above; Linux does not execute `.bat` files natively.
