#!/bin/bash
set -e

# Start Shiny server in background
echo "Starting Shiny server..."
shiny-server &

# Wait a few seconds to make sure Shiny starts
sleep 3

# Preload specific apps
echo "Warming up Shiny apps..."
curl -s http://localhost:3838/cancermine/ > /dev/null
curl -s http://localhost:3838/civicmine/ > /dev/null

# Start nginx in foreground (so Docker health checks work)
echo "Starting nginx..."
nginx -g "daemon off;"
