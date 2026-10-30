#!/usr/bin/env bash
# Installs the public-safety git hooks in this checkout (hooks are not versioned by git).
set -e
cd "$(git rev-parse --show-toplevel)"
printf '#!/usr/bin/env bash\nexec scripts/public-safety-check.sh --staged\n' > .git/hooks/pre-commit
printf '#!/usr/bin/env bash\nscripts/public-safety-check.sh && exec scripts/public-safety-check.sh --history\n' > .git/hooks/pre-push
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
echo "Installed pre-commit and pre-push public-safety hooks."
