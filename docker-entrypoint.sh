#!/bin/sh
set -e

mkdir -p /app/data

# Seed the backgrounds volume with the baked-in defaults (default.svg, any
# themes/) the first time it's mounted empty. A bind-mounted host directory
# starts empty and would otherwise shadow the images copied into the layer.
if [ -d /app/public/.backgrounds-seed ] && [ -z "$(ls -A /app/public/backgrounds 2>/dev/null)" ]; then
  cp -r /app/public/.backgrounds-seed/. /app/public/backgrounds/
fi

exec "$@"
