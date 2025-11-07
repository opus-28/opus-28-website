#!/usr/bin/env bash
set -eu

# preview.sh - start a static preview server and open a browser
# Usage: ./preview.sh [port]

PORT=${1:-8000}
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Serving $ROOT_DIR on port $PORT"

# If port is already in use, print info and keep running server
if command -v lsof >/dev/null 2>&1 && lsof -iTCP:$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
  PID=$(lsof -iTCP:$PORT -sTCP:LISTEN -t)
  echo "Port $PORT already in use by PID $PID"
else
  # Start server in background, log to /tmp/opus-preview.log
  nohup python3 -m http.server "$PORT" --directory "$ROOT_DIR" > /tmp/opus-preview.log 2>&1 &
  sleep 0.5
  echo "Server started (logs -> /tmp/opus-preview.log)"
fi

URL="http://localhost:$PORT"
echo "Preview available at: $URL"

# Try to open in user's browser
if [ -n "${BROWSER:-}" ]; then
  echo "Opening with \$BROWSER"
  "$BROWSER" "$URL" &>/dev/null || true
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$URL" >/dev/null 2>&1 || true
elif command -v sensible-browser >/dev/null 2>&1; then
  sensible-browser "$URL" >/dev/null 2>&1 || true
else
  echo "No auto-open command found. Open $URL in your browser."
fi

echo "To stop the server:"
echo "  pkill -f 'python3 -m http.server $PORT' || kill \$(lsof -iTCP:$PORT -sTCP:LISTEN -t)"
