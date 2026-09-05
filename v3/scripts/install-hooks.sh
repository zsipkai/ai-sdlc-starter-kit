#!/usr/bin/env bash

set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -d .git ]; then
  echo "Run this installer from a normal Git checkout."
  exit 1
fi

hook=.git/hooks/pre-commit
cp scripts/pre-commit "$hook"
chmod +x "$hook"

echo "Installed $hook"
echo "Mirror scripts/sdlc-gate.sh in CI before relying on this for team policy."
