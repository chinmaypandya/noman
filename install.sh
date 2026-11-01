#!/usr/bin/env bash
# noman installer. Run from your project root:
#   curl -fsSL https://raw.githubusercontent.com/chinmaypandya/noman/main/install.sh | bash
#
# - Copies the noman skill into ./.claude/skills/noman (replacing an older copy)
# - Touches nothing else: no CLAUDE.md, no other skills
set -euo pipefail

REPO="chinmaypandya/noman"
REF="${NOMAN_REF:-main}"
TARGET="$PWD"

for arg in "$@"; do
  case "$arg" in
    -h|--help) sed -n '2,6p' "$0" 2>/dev/null || true; exit 0 ;;
    *) echo "error: unknown option $arg" >&2; exit 1 ;;
  esac
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Use a local checkout when run from one; otherwise download.
src=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "$(dirname "${BASH_SOURCE[0]}")/skills/noman/SKILL.md" ]; then
  src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  command -v curl >/dev/null || { echo "error: curl is required" >&2; exit 1; }
  command -v tar  >/dev/null || { echo "error: tar is required" >&2; exit 1; }
  echo "Downloading $REPO@$REF ..."
  curl -fsSL "https://codeload.github.com/$REPO/tar.gz/$REF" | tar -xz -C "$tmp"
  src="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
fi

[ -f "$src/skills/noman/SKILL.md" ] || { echo "error: skills/noman missing in source" >&2; exit 1; }

mkdir -p "$TARGET/.claude/skills"
rm -rf "$TARGET/.claude/skills/noman"
cp -R "$src/skills/noman" "$TARGET/.claude/skills/noman"
echo "  skill: .claude/skills/noman"

if [ -f "$TARGET/CLAUDE.md" ] && grep -qF "<!-- noman:start -->" "$TARGET/CLAUDE.md"; then
  echo "  note: CLAUDE.md still has an old noman block (<!-- noman:start/end -->). It's no longer needed; you can delete it."
fi

echo
echo "Done. Start Claude Code in this project and describe the work, or start a request with /noman."
