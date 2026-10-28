#!/usr/bin/env bash
set -euo pipefail

CLIENT_ROOT="${1:-/mnt/e/_classic_beta_}"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/client-addons/WoWAscensionRework_CA"
TARGET_DIR="$CLIENT_ROOT/Interface/AddOns/WoWAscensionRework_CA"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Missing addon source: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$CLIENT_ROOT/Interface/AddOns"
rm -rf "$TARGET_DIR"
cp -a "$SOURCE_DIR" "$TARGET_DIR"

echo "Installed WoWAscensionRework_CA to: $TARGET_DIR"
echo "Expected addon title: Forever.Ascension CA Test"
echo "Expected version: 1.0.1"
echo "In-game commands: /wca  /ca2  /fa"
