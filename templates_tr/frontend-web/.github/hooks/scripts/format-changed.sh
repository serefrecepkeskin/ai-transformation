#!/usr/bin/env bash
# postToolUse hook'u: working tree'de değişen dosyaları otomatik formatlar.
# stdin'den hook JSON'ını okur ama şemasına bağımlı değildir; git durumuna göre
# çalışır, böylece Copilot sürümleri arasında bozulmaz. Asla engellemez:
# her zaman 0 ile çıkar. Windows: powershell varyantı yapılandırılmadı —
# ekip Windows'ta geliştiriyorsa TODO(confirm).
set -u
cat > /dev/null  # stdin'i boşalt

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
command -v npx > /dev/null 2>&1 || exit 0

changed=$( (git diff --name-only HEAD -- 2>/dev/null; git ls-files --others --exclude-standard) | sort -u )
[ -z "$changed" ] && exit 0

fmt=$(echo "$changed" | grep -E '\.(ts|tsx|js|jsx|vue|css|scss|json|md|yml|yaml)$')
if [ -n "$fmt" ]; then
  echo "$fmt" | xargs npx --no-install prettier --write > /dev/null 2>&1
fi

lint=$(echo "$changed" | grep -E '\.(ts|tsx|js|jsx|vue)$')
if [ -n "$lint" ]; then
  echo "$lint" | xargs npx --no-install eslint --fix > /dev/null 2>&1
fi

exit 0
