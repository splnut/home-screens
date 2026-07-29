# Docker

Runs the Home Screens **server** in a container — the editor, display, and
API. This does not include the Raspberry Pi kiosk pieces (Chromium, boot
splash, auto-login); for a self-contained Pi setup use `scripts/install.sh`
instead, or point a Pi in `--display-only` mode at a Docker host running the
server as its hub.

## Quick start

```bash
git clone https://github.com/home-screens/home-screens.git
cd home-screens
docker compose up -d --build
```

Then visit:
- `http://localhost:3000/editor` — configure your screens
- `http://localhost:3000/display` — fullscreen display view

## Persistent data

Two host directories are bind-mounted so your configuration and uploads
survive rebuilds:

| Host path              | Container path            | Contents                                   |
|-------------------------|---------------------------|---------------------------------------------|
| `./data`                | `/app/data`                | config, API keys, plugins, backups (JSON)  |
| `./public/backgrounds`  | `/app/public/backgrounds`  | uploaded/rotated background images & videos |

Both directories are created automatically on first run (and seeded with the
default background) if they don't already exist. Back them up together to
back up the whole app.

## Configuration

All API keys and integrations are configured through the editor UI at
**Settings > API keys** — no `.env` file required. The only environment
variable you might need is `NEXTAUTH_URL` in `docker-compose.yml`, if you're
using Google Calendar OAuth from a URL other than `http://localhost:3000`.

## Custom port

```yaml
ports:
  - "8080:3000"
```

The app listens on `3000` inside the container regardless — only the host
side of the mapping needs to change.

## Rebuilding after an update

```bash
git pull
docker compose up -d --build
```

Your `data/` and `public/backgrounds/` volumes are untouched by rebuilds.
