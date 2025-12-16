#!/bin/bash
set -e

echo "Warming up Shiny apps..."
sleep 120
curl -s -o /dev/null http://localhost:3838/cancermine/

sleep 120
curl -s -o /dev/null http://localhost:3838/civicmine/
