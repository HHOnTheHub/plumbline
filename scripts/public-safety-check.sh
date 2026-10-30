#!/usr/bin/env bash
# Public-safety scan for the Plumbline repository. See PUBLIC-SAFETY.md.
#
#   scripts/public-safety-check.sh            scan every tracked file
#   scripts/public-safety-check.sh --staged   scan what is staged (used by the pre-commit hook)
#   scripts/public-safety-check.sh --history  scan every commit's changes
#
# Generic patterns live here. An operator's private names list (organisations, apps,
# domains, people) is read from $PLUMBLINE_DENYLIST, or ../plumbline-ops/public-denylist.txt,
# and never enters this repository. Exit code 1 means something must be removed.
set -u
cd "$(git rev-parse --show-toplevel)" || exit 2

MODE="${1:-all}"
SELF="scripts/public-safety-check.sh"
SKIP_RE='^(LICENSE|LICENSE-docs\.md|scripts/public-safety-check\.sh|scripts/public-safety-allow\.txt)$'
ALLOW_FILE="scripts/public-safety-allow.txt"
DENY="${PLUMBLINE_DENYLIST:-../plumbline-ops/public-denylist.txt}"
[ -f "$DENY" ] && DENY="$(cd "$(dirname "$DENY")" && pwd)/$(basename "$DENY")"

PATTERNS=(
  'sk-[A-Za-z0-9_-]{20,}'                         # API keys (sk-…)
  'gh[pousr]_[A-Za-z0-9]{30,}'                    # GitHub tokens
  'xox[baprs]-[A-Za-z0-9-]{10,}'                  # Slack tokens
  'AKIA[0-9A-Z]{16}'                              # AWS access keys
  're_[A-Za-z0-9]{24,}'                           # Resend keys
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'            # private keys
  'eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{15,}'     # JWTs (Supabase keys)
  '[a-z0-9]{20}\.supabase\.(co|in)'               # Supabase project URLs
  '/Users/[A-Za-z0-9._-]+/'                       # macOS home paths
  '/home/[A-Za-z0-9._-]+/'                        # Linux home paths
  'C:\\Users\\'                               # Windows home paths
  'claude\.ai/(code/)?artifact/'                  # links to private artifacts
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' # email addresses (allow-list below)
)

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
tmp="$work/files"; mkdir -p "$tmp"
case "$MODE" in
  --staged)  git diff --cached --name-only --diff-filter=ACM | grep -Ev "$SKIP_RE" | while read -r f; do mkdir -p "$tmp/$(dirname "$f")"; git show ":$f" > "$tmp/$f" 2>/dev/null; done ;;
  --history) git log -p --all --no-color | grep '^+' | grep -v '^+++' > "$tmp/history.txt" ;;
  *)         git ls-files | grep -Ev "$SKIP_RE" | while read -r f; do [ -f "$f" ] && { mkdir -p "$tmp/$(dirname "$f")"; cp "$f" "$tmp/$f"; }; done ;;
esac

found=0
hits="$work/hits"; : > "$hits"
for p in "${PATTERNS[@]}"; do
  ( cd "$tmp" && grep -rnIE -e "$p" . 2>/dev/null ) >> "$hits"
done
# Drop allowed matches (one extended regex per line in the allow file)
if [ -s "$hits" ] && [ -f "$ALLOW_FILE" ]; then
  grep -vE -f <(grep -vE '^\s*(#|$)' "$ALLOW_FILE") "$hits" > "$hits.f" || true; mv "$hits.f" "$hits"
fi
if [ -s "$hits" ]; then
  echo "Public-safety: generic patterns found (secrets, private paths, private links or emails):"
  sed 's|^\./||' "$hits" | cut -c1-200
  found=1
fi

if [ -f "$DENY" ]; then
  names="$work/names"
  ( cd "$tmp" && grep -rnIiwF -f <(grep -vE '^\s*(#|$)' "$DENY") . 2>/dev/null ) > "$names"
  if [ -s "$names" ]; then
    echo "Public-safety: names from the private list found (remove them; never copy the list here):"
    sed 's|^\./||' "$names" | cut -d: -f1,2 | sort -u
    found=1
  fi
else
  [ "${CI:-}" = "true" ] || echo "Public-safety: note: private names list not found at $DENY; only generic checks ran."
fi

[ $found -eq 0 ] && echo "Public-safety: clean ($MODE)."
exit $found
