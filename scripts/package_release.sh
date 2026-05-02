#!/usr/bin/env bash
set -euo pipefail
VERSION=${1:-$(date +%Y%m%d-%H%M%S)}
OUT="release/remesys-${VERSION}.tar.gz"
mkdir -p release

tar --exclude='.git' --exclude='release' --exclude='*.log' -czf "$OUT" .
echo "$OUT"
