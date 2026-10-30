#!/usr/bin/env bash
# Builds a release folder for this machine's platform and zips it:
#
#   dist/tms-<version>-<platform>/
#     tms (tms.exe on Windows)   the server, with PostgreSQL bundled inside
#     web/                       the web client
#     README.txt
#
# On first start the server creates data/ next to itself for the database, logs and backups.
set -euo pipefail
cd "$(dirname "$0")/.."

version=$(sed -n 's/^version = "\(.*\)"/\1/p' Cargo.toml | head -n 1)
case "$(uname -s)" in
  Linux) os=linux ;;
  Darwin) os=macos ;;
  MINGW* | MSYS* | CYGWIN*) os=windows ;;
  *) os=$(uname -s | tr '[:upper:]' '[:lower:]') ;;
esac
name="tms-$version-$os-$(uname -m)"
out="dist/$name"

# dx keeps older hashed files in its output folder; clear it so only this build ships.
rm -rf target/dx/tms-client/release/web/public "$out" "dist/$name.zip"
dx build --package tms-client --platform web --release
cargo build --release --package tms-launcher

mkdir -p "$out"
bin=target/release/tms
[ -f "$bin.exe" ] && bin="$bin.exe"
cp "$bin" "$out/"
cp -r target/dx/tms-client/release/web/public "$out/web"
cp scripts/release-readme.txt "$out/README.txt"

(cd dist && if command -v zip > /dev/null; then zip -qr "$name.zip" "$name"; else 7z a -tzip "$name.zip" "$name" > /dev/null; fi)
echo "$out"
echo "Built $out ($(du -sh "$out" | cut -f1)) and dist/$name.zip ($(du -h "dist/$name.zip" | cut -f1))"
