#!/usr/bin/env bash
set -euo pipefail

REPO="${WEMS_REPO:-SearisIQ/wems}"
BRANCH="${WEMS_BRANCH:-main}"
DEST="${WEMS_BIN:-$HOME/.local/bin}"

[[ "$(uname)" == "Darwin" ]] || { echo "WEMS only runs on macOS." >&2; exit 1; }

mkdir -p "$DEST"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

src="${BASH_SOURCE[0]:-}"
here=""; [[ -n "$src" && -f "$src" ]] && here="$(cd "$(dirname "$src")" && pwd)"
if [[ -n "$here" && -f "$here/wems" ]]; then
  cp "$here/wems" "$tmp"
else
  curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/wems" -o "$tmp"
fi
head -1 "$tmp" | grep -q bash || { echo "Download failed: not the wems script." >&2; exit 1; }
chmod +x "$tmp"
mv "$tmp" "$DEST/wems"
echo "✓ Installed wems to $DEST/wems"

case ":$PATH:" in
  *":$DEST:"*) ;;
  *)
    rc="$HOME/.zshrc"; [[ "${SHELL:-}" == */bash ]] && rc="$HOME/.bash_profile"
    if ! grep -qs "$DEST" "$rc"; then
      printf '\n# Added by the WEMS installer\nexport PATH="%s:$PATH"\n' "$DEST" >>"$rc"
      echo "✓ Added $DEST to PATH in $rc"
    fi
    echo "  Open a new terminal (or run: source $rc) before using wems."
    ;;
esac
echo "  Run: wems"
