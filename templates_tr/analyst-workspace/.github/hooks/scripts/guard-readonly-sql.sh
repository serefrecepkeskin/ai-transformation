#!/usr/bin/env bash
# preToolUse hook'u: AGENTS.md kural #1'in (salt okunur) teknik zorlaması.
# Her tool çağrısının JSON girdisini yazma/DDL SQL kalıpları için tarar ve
# eşleşme olursa çağrıyı REDDEDER. Derinlemesine savunma: asıl koruma yine
# salt okunur DB kullanıcısıdır — bu hook hatayı yalnızca daha erken yakalar.
# Nadiren, böyle bir SQL'i yalnızca metin olarak alıntılayan zararsız bir
# çağrıyı da reddedebilir; ret gerekçesi bunu açıklar, analist yeniden ifade eder.
# Windows: powershell varyantı yapılandırılmadı — TODO(confirm).
set -u
input=$(cat)

if printf '%s' "$input" | grep -qiE '\b(insert[[:space:]]+into|update[[:space:]]+[[:alnum:]_."]+[[:space:]]+set|delete[[:space:]]+from|drop[[:space:]]+(table|database|schema|index|view)|truncate([[:space:]]+table)?|alter[[:space:]]+(table|database|schema)|create[[:space:]]+(table|database|schema|index)|grant[[:space:]]+|revoke[[:space:]]+)\b'; then
  printf '{"permissionDecision":"deny","permissionDecisionReason":"Bu calisma alani salt okunurdur (AGENTS.md kural #1): hicbir veritabaninda yazma/DDL SQL calistirilamaz. Veri degismesi gerekiyorsa bunu gelistiricilere giden task icine yaz."}'
  exit 0
fi

# Boş çıktı = varsayılan izin davranışı.
exit 0
