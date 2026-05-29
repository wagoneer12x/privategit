#!/usr/bin/env bash
set -eo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

REMOTE_URL=""
USER_NAME=""
USER_EMAIL=""
ENABLE_GIT_CRYPT=0
ENABLE_PSEUDO_ENCRYPT=0
KEY_OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)
      REMOTE_URL="${2:-}"
      shift 2
      ;;
    --name)
      USER_NAME="${2:-}"
      shift 2
      ;;
    --email)
      USER_EMAIL="${2:-}"
      shift 2
      ;;
    --git-crypt)
      ENABLE_GIT_CRYPT=1
      shift
      ;;
    --pseudo-encrypt-commits)
      ENABLE_PSEUDO_ENCRYPT=1
      shift
      ;;
    --key-output)
      KEY_OUTPUT="${2:-}"
      shift 2
      ;;
    *)
      echo "usage: .hooks/scripts/setup.sh [--remote URL] [--name NAME] [--email EMAIL] [--git-crypt] [--pseudo-encrypt-commits] [--key-output PATH]"
      exit 1
      ;;
  esac
done

git config --local core.hooksPath .hooks
git config --local include.path ../.gitconfig

if [[ -n "$REMOTE_URL" ]]; then
  git remote add origin "$REMOTE_URL" 2>/dev/null || git remote set-url origin "$REMOTE_URL"
  echo "🪝 setup: origin -> $REMOTE_URL"
fi

if [[ -n "$USER_NAME" ]]; then
  git config --local user.name "$USER_NAME"
  echo "🪝 setup: user.name -> $USER_NAME"
fi

if [[ -n "$USER_EMAIL" ]]; then
  git config --local user.email "$USER_EMAIL"
  echo "🪝 setup: user.email -> $USER_EMAIL"
fi

if [[ "$ENABLE_GIT_CRYPT" -eq 1 ]]; then
  command -v git-crypt >/dev/null 2>&1 || { echo "🪝 setup: BLOCKED — git-crypt not installed"; exit 1; }
  git-crypt init
  python3 - <<'PY' "$ROOT/.gitattributes"
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
old = "# * filter=git-crypt diff=git-crypt"
new = "* filter=git-crypt diff=git-crypt"
if old in text:
    path.write_text(text.replace(old, new, 1))
PY
  git add .gitattributes
  if [[ -n "$KEY_OUTPUT" ]]; then
    git-crypt export-key "$KEY_OUTPUT"
    echo "🪝 setup: git-crypt key -> $KEY_OUTPUT"
  fi
  echo "🪝 setup: git-crypt enabled"
fi

if [[ "$ENABLE_PSEUDO_ENCRYPT" -eq 1 ]]; then
  git config --local hooks.pseudoEncryptCommits true
  echo "🪝 setup: pseudo-encrypt-commits enabled"
else
  git config --local --unset-all hooks.pseudoEncryptCommits 2>/dev/null || true
fi

echo "🟢 setup: done"
