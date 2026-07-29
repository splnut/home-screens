# syntax=docker/dockerfile:1

# Home Screens runs great bare-metal on a Pi (see scripts/install.sh), but
# this image lets you run the same Next.js app anywhere Docker runs. It does
# NOT replace the kiosk/Chromium side of a Pi install — it's the server only;
# point a browser (or a Pi in --display-only mode) at it.

FROM node:22-alpine AS builder
WORKDIR /app
# .npmrc pins engine-strict=true and package.json requires npm >=11.6.3,
# which is newer than what ships with the node:22 image.
RUN npm install -g npm@^11.6.3
# postinstall (scripts/copy-font-awesome.mjs) needs more than the lockfile,
# so the full source is copied before `npm ci` rather than caching a
# lockfile-only deps layer.
COPY . .
RUN npm ci
RUN NODE_OPTIONS='--max-old-space-size=3072' npm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

# output: 'standalone' (next.config.mjs) traces the server + node_modules but
# not public/ or .next/static, and not the runtime data/ tree the app reads
# and writes via process.cwd() (secrets, config, plugins, uploaded
# backgrounds) — those are copied/created below and expected to be mounted
# as volumes in docker-compose.yml so they survive container recreation.
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Preserve the baked-in default background/theme assets separately so the
# entrypoint can reseed them into an empty bind-mounted volume on first run
# (a fresh host directory would otherwise shadow public/backgrounds/*).
RUN cp -r /app/public/backgrounds /app/public/.backgrounds-seed && \
    mkdir -p /app/data

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -q -O /dev/null "http://127.0.0.1:${PORT}/" || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "server.js"]
