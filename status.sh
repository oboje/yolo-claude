#!/usr/bin/env bash
set -uo pipefail

IMAGE=claude-vm
MACHINE=claude

command -v container >/dev/null || { echo "container    NOT INSTALLED"; exit 1; }

row() { printf '%-12s %s\n' "$1" "$2"; }

row container "$(container --version)"
row service   "$(container system status 2>/dev/null | awk '$1=="status"{print $2}')"

if container image ls -q | grep -q "^${IMAGE}:"; then
  row image "$IMAGE present"
else
  row image "$IMAGE MISSING (run up.sh)"
fi

echo
container machine ls

state=$(container machine ls --format json 2>/dev/null \
  | tr '{' '\n' | grep "\"id\":\"${MACHINE}\"" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
echo
if [ "$state" != "running" ]; then
  row machine "${state:-absent} - start it with up.sh"
  exit 0
fi

run() { container machine run -n "$MACHINE" -- "$@" 2>/dev/null; }
row claude  "$(run claude --version || echo 'NOT FOUND')"
row user    "$(run whoami)@$(run pwd)"
row session "$(run du -sh .claude | cut -f1 || echo 'not logged in')"
row tmux    "$(run tmux ls | tr '\n' ' ' || echo 'no sessions')"
