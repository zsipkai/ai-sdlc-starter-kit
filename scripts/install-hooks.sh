#!/usr/bin/env bash
# Installs the git pre-commit hook that enforces the fast SDLC gate.
# Run once after cloning: bash scripts/install-hooks.sh

set -euo pipefail
cd "$(dirname "$0")/.."

HOOK=.git/hooks/pre-commit
cat > "$HOOK" <<'EOF'
#!/usr/bin/env bash
# Auto-installed by scripts/install-hooks.sh — do not edit here, edit the installer.
echo "pre-commit: running SDLC fast gate (doc-drift + backend tests)..."
bash scripts/sdlc-gate.sh --fast
EOF
chmod +x "$HOOK"
echo "Installed $HOOK"
echo "Every commit now runs: doc-drift checks + backend test suite."
echo "Emergency bypass: git commit --no-verify (be ready to justify it in review)."
