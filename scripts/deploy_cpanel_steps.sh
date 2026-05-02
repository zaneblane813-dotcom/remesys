#!/usr/bin/env bash
set -euo pipefail
if [ $# -lt 2 ]; then
  echo "Usage: $0 <release-tar.gz> <target-path>"
  exit 1
fi
PKG="$1"
TARGET="$2"
mkdir -p "$TARGET"
tar -xzf "$PKG" -C "$TARGET"
cp "$TARGET/public/.htaccess" "$TARGET/.htaccess"

echo "Deployed to $TARGET"
echo "Next: configure config/config.php DB creds and export REMESYS_API_KEY"
