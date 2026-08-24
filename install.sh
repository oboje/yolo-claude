#!/usr/bin/env bash
# Fetch and install the latest apple/container release. Needs sudo for `installer`.
set -euo pipefail

REPO=apple/container
LOG="${TMPDIR:-/tmp}/container-install-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1

log() { printf '%s  %s\n' "$(date +%H:%M:%S)" "$*"; }

log "log file: $LOG"

[ "$(uname -m)" = arm64 ] || { log "FAIL: Apple silicon required"; exit 1; }
log "macOS $(sw_vers -productVersion), arch $(uname -m)"

log "querying latest release of $REPO"
TAG=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
      | grep -m1 '"tag_name"' | cut -d'"' -f4)
[ -n "$TAG" ] || { log "FAIL: could not read tag_name"; exit 1; }
log "latest is $TAG"

if HAVE=$(container --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1); then
  log "installed: $HAVE"
  [ "$HAVE" = "$TAG" ] && { log "already up to date, nothing to do"; exit 0; }
fi

PKG="container-${TAG}-installer-signed.pkg"
URL="https://github.com/$REPO/releases/download/$TAG/$PKG"
DEST="${TMPDIR:-/tmp}/$PKG"

log "downloading $URL"
curl -fL --progress-bar "$URL" -o "$DEST"
log "downloaded $(du -h "$DEST" | cut -f1)"

log "checking signature"
pkgutil --check-signature "$DEST" | sed -n '1,4p'

log "installing (sudo password required)"
sudo installer -pkg "$DEST" -target /

log "installed: $(container --version)"
log "starting service"
container system start
container system status

rm -f "$DEST"
log "done"
