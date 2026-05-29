#!/bin/bash
# health-check.sh - Git health check before push
# Checks: large files (>90MB), embedded git repos
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SIZE_MB="${1:-90}"
LIMIT=$((SIZE_MB * 1024 * 1024))
cd "$ROOT" || exit 1

is_lfs_pointer_file() {
  [[ -f "$1" ]] || return 1
  head -1 "$1" 2>/dev/null | grep -q "^version https://git-lfs.github.com/spec/v1"
}
skip_largefile_check() {
  local f="$1"
  [[ "$f" == *.enc ]] && return 0
  is_lfs_pointer_file "$f" && return 0
  return 1
}

ISSUES=0
echo "🏥 Git Health Check: $ROOT"
echo ""
echo "🔍 Checking for files > ${SIZE_MB}MB..."

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  if [[ -f "$file" ]]; then
    skip_largefile_check "$file" && continue
    fsize=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
    if [[ "$fsize" -gt "$LIMIT" ]]; then
      size_human=$((fsize / 1024 / 1024))
      echo "  🔴 $file (${size_human}MB)"
      ISSUES=1
    fi
  fi
done < <(git diff --cached --name-only 2>/dev/null)

echo ""
echo "🔍 Checking for embedded git repos..."
ROOT_GIT="$ROOT/.git"
while IFS= read -r git_dir; do
  [[ -z "$git_dir" ]] && continue
  [[ "$git_dir" == "$ROOT_GIT" ]] && continue
  repo_dir="${git_dir%/.git}"
  relative="${repo_dir#$ROOT/}"
  is_tracked=false
  if command -v rg &>/dev/null; then
    git ls-files --cached "$relative" 2>/dev/null | rg -q . && is_tracked=true
  else
    git ls-files --cached "$relative" 2>/dev/null | grep -q . && is_tracked=true
  fi
  is_ignored=false
  git check-ignore -q "$relative" 2>/dev/null && is_ignored=true
  if [[ "$is_tracked" == "true" ]]; then
    echo "  🔴 $relative (TRACKED embedded repo)"
    ISSUES=1
  elif [[ "$is_ignored" == "false" ]]; then
    echo "  🟡 $relative (not ignored embedded repo)"
    ISSUES=1
  fi
done < <(find "$ROOT" -type d -name ".git" 2>/dev/null | sort)

if [[ $ISSUES -eq 0 ]]; then
  echo "🟢 All checks passed"
  exit 0
else
  echo "🔴 Issues found - fix before pushing"
  exit 1
fi
