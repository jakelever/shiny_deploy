#!/bin/bash
set -e

# Start Shiny server in background
echo "Starting Shiny server..."
shiny-server &

# Wait a few seconds to make sure Shiny starts
sleep 3

# Preload specific apps
bash /usr/local/bin/warmup.sh &

# Start nginx in foreground (so Docker health checks work)
echo "Starting nginx..."
nginx -g "daemon off;"
