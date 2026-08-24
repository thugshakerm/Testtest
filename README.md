# Easy Hexagon setup

This small wrapper makes the public [Hexagon](https://github.com/randomyaps/Hexagon) source easier to install. It does not redistribute Hexagon; the setup script clones it from GitHub.

> **Important:** Hexagon's upstream README says not to publicly re-host it and notes that its arbiter is not included. Review the source and its license/permissions before exposing it through Cloudflare. The simplified stack starts the web app and PostgreSQL only; game launching/rendering will need the missing services configured separately.

## VPS (Linux)

```bash
git clone https://github.com/thugshakerm/Testtest.git hexagon-installer
cd hexagon-installer
nano config.env                 # set DB_PASSWORD; SITE_DOMAIN is optional
chmod +x setup.sh git-pull.sh
./setup.sh
```

The app is bound to `127.0.0.1:9000`, which is appropriate for a Cloudflare Tunnel/route on the same VPS. The setup script creates `hexagon/.env`, generates local secrets, creates a minimal Compose file, runs migrations, and starts the app.

To update later:

```bash
./git-pull.sh
```

## Configuration

Copy `config.env.example` to `config.env`. The only required secret is `DB_PASSWORD`. Set `SITE_DOMAIN` to the hostname used by Cloudflare if you want generated legacy game URLs to use that hostname; otherwise it defaults to `localhost:9000` for local testing.

Never commit `config.env`.

## Windows

`setup.bat` and `git-pull.bat` are included for a Windows machine with Docker Desktop and Git. A normal Linux VPS should use the `.sh` files above; Linux does not execute `.bat` files natively.
