#!/usr/bin/env bash
set -euo pipefail
exec container machine run -n claude -- tmux new -A -s main
