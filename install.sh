#!/usr/bin/env bash
# thousand_sunny installer. Run from your project root:
#   curl -fsSL https://raw.githubusercontent.com/chinmaypandya/thousand_sunny/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/chinmaypandya/thousand_sunny/main/install.sh | bash -s -- --no-ponytail
#
# - Copies noman (and ponytail, unless --no-ponytail or PONYTAIL=0) into ./.claude/skills/
# - Adds the routing rules to ./CLAUDE.md (creates it if missing)
# - Safe to re-run: the CLAUDE.md block is replaced in place, never duplicated
set -euo pipefail

REPO="chinmaypandya/thousand_sunny"
REF="${THOUSAND_SUNNY_REF:-main}"
START="<!-- thousand_sunny:start -->"
END="<!-- thousand_sunny:end -->"
TARGET="$PWD"

PONYTAIL="${PONYTAIL:-1}"
for arg in "$@"; do
  case "$arg" in
    --no-ponytail) PONYTAIL=0 ;;
    --with-ponytail) PONYTAIL=1 ;;
    -h|--help) sed -n '2,8p' "$0" 2>/dev/null || true; exit 0 ;;
    *) echo "error: unknown option $arg (use --no-ponytail)" >&2; exit 1 ;;
  esac
done
SKILLS="noman"
[ "$PONYTAIL" = "0" ] || SKILLS="noman ponytail"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Use a local checkout when run from one; otherwise download.
src=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -d "$(dirname "${BASH_SOURCE[0]}")/skills/noman" ] && [ -f "$(dirname "${BASH_SOURCE[0]}")/CLAUDE.md" ]; then
  src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  command -v curl >/dev/null || { echo "error: curl is required" >&2; exit 1; }
  command -v tar  >/dev/null || { echo "error: tar is required" >&2; exit 1; }
  echo "Downloading $REPO@$REF ..."
  curl -fsSL "https://codeload.github.com/$REPO/tar.gz/$REF" | tar -xz -C "$tmp"
  src="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
fi

[ -f "$src/CLAUDE.md" ] || { echo "error: CLAUDE.md missing in source" >&2; exit 1; }

# 1. Skills
mkdir -p "$TARGET/.claude/skills"
for name in $SKILLS; do
  [ -d "$src/skills/$name" ] || { echo "error: skills/$name missing in source" >&2; exit 1; }
  rm -rf "$TARGET/.claude/skills/$name"
  cp -R "$src/skills/$name" "$TARGET/.claude/skills/$name"
  echo "  skill: .claude/skills/$name"
done

# 2. CLAUDE.md: append, or replace our block if already installed
block="$tmp/block.md"
{ echo "$START"; cat "$src/CLAUDE.md"; echo; echo "$END"; } > "$block"

claude_md="$TARGET/CLAUDE.md"
if [ ! -f "$claude_md" ]; then
  cp "$block" "$claude_md"
  echo "  created CLAUDE.md"
elif grep -qF "$START" "$claude_md" && grep -qF "$END" "$claude_md"; then
  awk -v s="$START" -v e="$END" -v b="$block" '
    $0==s { while ((getline line < b) > 0) print line; skip=1; next }
    $0==e { skip=0; next }
    !skip { print }
  ' "$claude_md" > "$tmp/new.md"
  cat "$tmp/new.md" > "$claude_md"
  echo "  updated thousand_sunny block in CLAUDE.md"
else
  { echo; cat "$block"; } >> "$claude_md"
  echo "  appended to existing CLAUDE.md"
fi

echo
echo "Done: installed $SKILLS. Start Claude Code in this project and describe the work."
