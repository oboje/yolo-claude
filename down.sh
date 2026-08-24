#!/usr/bin/env bash
set -euo pipefail

MACHINE=claude

case "${1:-stop}" in
  stop)  container machine stop "$MACHINE" ;;
  rm)    container machine rm "$MACHINE" ;;
  purge) container machine rm "$MACHINE"; container image rm claude-vm ;;
  *)     echo "usage: down.sh [stop|rm|purge]"; exit 1 ;;
esac
