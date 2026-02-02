#!/usr/bin/env bash
set -e

PORT=${PORT:-${APP_PORT:-8124}}
HOST=${APP_HOST:-0.0.0.0}
DEBUG=${APP_DEBUG:-false}

export APP_HOST=$HOST
export APP_PORT=$PORT
export APP_DEBUG=$DEBUG

echo "Starting Boodschappenplanner on ${HOST}:${PORT} (debug=${DEBUG})"
exec python app.py

