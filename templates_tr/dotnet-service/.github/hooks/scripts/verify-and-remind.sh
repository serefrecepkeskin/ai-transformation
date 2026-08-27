#!/usr/bin/env bash
# agentStop hook'u: oturum sonu kontrolleri. Formatlama her edit'te
# (postToolUse) değil burada koşar; dotnet format tüm solution'ı taradığı için
# tool çağrısı başına çok yavaştır — bilinçli tercih. Engellemez: her zaman
# 0 ile çıkar. Windows: powershell varyantı yapılandırılmadı — TODO(confirm).
set -u
cat > /dev/null  # stdin'i boşalt

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
changed=$( (git diff --name-only HEAD -- 2>/dev/null; git ls-files --others --exclude-standard) | sort -u )
[ -z "$changed" ] && exit 0

if echo "$changed" | grep -qE '\.cs$' && command -v dotnet > /dev/null 2>&1; then
  if ! dotnet format --verify-no-changes > /dev/null 2>&1; then
    echo "Hatirlatma: 'dotnet format --verify-no-changes' basarisiz. PR oncesi 'dotnet format' calistir (run-quality-gates skill'i)."
  fi
fi

src=$(echo "$changed" | grep -vE '^docs/' | grep -E '\.cs$|\.csproj$|Directory\.Build\.props')
docs=$(echo "$changed" | grep -E '^docs/')

if [ -n "$src" ] && [ -z "$docs" ]; then
  echo "Hatirlatma: kaynak/konfig degisti ama docs/ guncellenmedi. Degisiklik mimariyi, konvansiyonlari ya da yigini etkiliyorsa dokumani guncelle ve ayni PR'da ADR kaydet (AGENTS.md kural #7)."
fi

if echo "$changed" | grep -qE '\.csproj$|Directory\.Build\.props' && ! echo "$changed" | grep -qE '^docs/decisions/'; then
  echo "Hatirlatma: proje/bagimlilik dosyalari degisti ama yeni ADR eklenmedi. Yigin/arac karari genellikle ADR ister (record-decision skill'i)."
fi

exit 0
