#!/usr/bin/env bash
# postToolUse hook'u: working tree'de değişen Python dosyalarını otomatik
# formatlar. stdin'den hook JSON'ını okur ama şemasına bağımlı değildir; git
# durumuna göre çalışır. Asla engellemez: her zaman 0 ile çıkar.
# Windows: powershell varyantı yapılandırılmadı — TODO(confirm).
set -u
cat > /dev/null  # stdin'i boşalt

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

changed=$( (git diff --name-only HEAD -- 2>/dev/null; git ls-files --others --exclude-standard) | sort -u | grep -E '\.py$' )
[ -z "$changed" ] && exit 0

if command -v uv > /dev/null 2>&1; then
  RUFF="uv run ruff"
elif command -v ruff > /dev/null 2>&1; then
  RUFF="ruff"
else
  exit 0
fi

echo "$changed" | xargs $RUFF format > /dev/null 2>&1
echo "$changed" | xargs $RUFF check --fix > /dev/null 2>&1

exit 0
