#!/bin/bash
set -e

# Start Shiny server in background
echo "Starting Shiny server..."
shiny-server &

# Wait a few seconds to make sure Shiny starts
sleep 3

# Preload specific apps
# bash /usr/local/bin/warmup.sh &

# Remove nginx's stock default site (it clashes with our default_server landing page). The Dockerfile also
# removes it, but that deletion can be lost when an image is built from cached layers (e.g. with Kaniko)
rm -f /etc/nginx/sites-enabled/default

# Start nginx in foreground (so Docker health checks work)
echo "Starting nginx..."
nginx -g "daemon off;"
