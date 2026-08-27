#!/usr/bin/env bash
# agentStop hook'u: oturum kod değişmiş ama bilgi tabanı dokunulmamış halde
# biterse engellemeyen hatırlatmalar basar (doküman ve kod birbirinden
# kopmamalı — AGENTS.md). Her zaman 0 ile çıkar.
set -u
cat > /dev/null  # stdin'i boşalt

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
changed=$( (git diff --name-only HEAD -- 2>/dev/null; git ls-files --others --exclude-standard) | sort -u )
[ -z "$changed" ] && exit 0

src=$(echo "$changed" | grep -vE '^docs/' | grep -E '\.(ts|tsx|js|jsx|vue|css|scss)$|package\.json|tsconfig')
docs=$(echo "$changed" | grep -E '^docs/')

if [ -n "$src" ] && [ -z "$docs" ]; then
  echo "Hatirlatma: kaynak/konfig degisti ama docs/ guncellenmedi. Degisiklik mimariyi, konvansiyonlari ya da yigini etkiliyorsa dokumani guncelle ve ayni PR'da ADR kaydet (AGENTS.md kural #7)."
fi

if echo "$changed" | grep -qE 'package\.json|tsconfig' && ! echo "$changed" | grep -qE '^docs/decisions/'; then
  echo "Hatirlatma: bagimlilik/konfig dosyalari degisti ama yeni ADR eklenmedi. Yigin/arac karari genellikle ADR ister (record-decision skill'i)."
fi

exit 0
