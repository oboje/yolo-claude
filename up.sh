#!/usr/bin/env bash
set -euo pipefail

IMAGE=claude-vm
MACHINE=claude
SESSION=main
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command -v container >/dev/null || { echo "container CLI not installed"; exit 1; }

container system status >/dev/null 2>&1 || container system start

container image ls -q | grep -q "^${IMAGE}:" \
  || container build -t "$IMAGE" "$DIR"

# `machine create` boots it; there is no `machine start` subcommand
container machine ls -q | grep -qx "$MACHINE" \
  || container machine create "$IMAGE" --name "$MACHINE" --home-mount none

# -it is required: without it tmux reports "open terminal failed: not a terminal"
exec container machine run -n "$MACHINE" -it -- \
  tmux new -A -s "$SESSION" claude --dangerously-skip-permissions
