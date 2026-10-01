#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/.agents/skills"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$DEST"

install_skill() {
  local repo="$1"
  local src="$2"
  local name="$3"
  local repo_dir="$TMP/$(echo "$repo" | tr '/' '_')"

  if [[ ! -d "$repo_dir/.git" ]]; then
    git clone --depth=1 "https://github.com/${repo}.git" "$repo_dir"
  fi

  if [[ ! -f "$repo_dir/$src/SKILL.md" ]]; then
    echo "Missing SKILL.md: $repo/$src" >&2
    exit 1
  fi

  rm -rf "$DEST/$name"
  cp -a "$repo_dir/$src" "$DEST/$name"
  echo "Installed $name from $repo/$src"
}

# HyperDroid: general ADB/build/fastboot/LineageOS layer.
install_skill "hyperb1iss/hyperdroid-skill" "skills/android" "upstream-hyperdroid-android"
install_skill "hyperb1iss/hyperdroid-skill" "skills/android-build" "upstream-hyperdroid-android-build"
install_skill "hyperb1iss/hyperdroid-skill" "skills/android-fastboot" "upstream-hyperdroid-android-fastboot"
install_skill "hyperb1iss/hyperdroid-skill" "skills/lineageos" "upstream-hyperdroid-lineageos"

# rasy007: focused ADB and crash-analysis helpers.
install_skill "rasy007/android-skills" "android-adb-toolkit" "upstream-rasy-adb-toolkit"
install_skill "rasy007/android-skills" "android-crash-analyzer" "upstream-rasy-crash-analyzer"

# aihip: APK inspection for OEM/stock application artifacts.
install_skill "aihip/android-claude-code-skills" "skills/apk-analyzer" "upstream-aihip-apk-analyzer"

echo
echo "Upstream skills installed under $DEST"
echo "Review upstream licenses and changes before committing vendored copies."
