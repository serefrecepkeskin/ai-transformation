# Konvansiyonlar

> **PLACEHOLDER** — TODO'ları bu kod tabanında gerçekten gözlemlenen
> konvansiyonlarla değiştirmek için `bootstrap-research` skill'ini çalıştır.
> Buraya yalnızca araçların (linter/formatter) zaten zorlamadığı kurallar girer.

## Genel

- Her yerde TypeScript strict; `any` yalnızca yazılı gerekçeyle.
- Formatlama: TODO(confirm) (araç + konfig).
- Commit & PR: İngilizce conventional-commit başlık, Türkçe gövde/açıklama —
  bkz. `commit-and-pr` skill'i. TODO(confirm): nasıl zorlanıyor (commitlint?).

## Bileşenler

- Konum & isimlendirme: TODO (dizin şeması, PascalCase/kebab, birlikte konumlandırma kuralları).
- Prop tipleme ve kompozisyon desenleri: TODO.
- Stil: TODO (utility class / CSS modules / token) — ve neyin yasak olduğu,
  ör. hardcoded hex değerler.

## State & veri

- Neyin global state'e, neyin bileşen state'ine, neyin URL'e ait olduğu: TODO.
- Veri çekme deseni ve hata ele alma kontratı: TODO.

## i18n

- Kullanıcıya görünen metin **asla** hardcoded değildir — her zaman i18n
  mekanizmasından geçer: TODO(confirm) (kütüphane, anahtar isimlendirmesi,
  dil dosyaları, desteklenen diller).

## Erişilebilirlik

- Etkileşimli öğeler: önce semantik HTML; TODO (bileşen kütüphanesi a11y kuralları).

## Test edilebilirlik

- E2E/entegrasyon hedefi olan öğelere `data-testid` ekle.

## Dallanma & PR'lar

- Dal adları: conventional-commit tipiyle `<tip>/<kebab-aciklama>`.
- PR başlığı: geçerli conventional commit (squash commit'i o olur).
- TODO(confirm): bu commit'leri okuyan bir sürüm otomasyonu var mı.

## Otomatik guardrail'ler (Copilot hook'ları & onaylar)

- `.github/hooks/format-and-docs.json` — **postToolUse** değişen dosyaları
  otomatik formatlar (prettier + eslint --fix); **agentStop** kod değişip
  `docs/` değişmediğinde (drift) ya da bağımlılık ADR'sız değiştiğinde
  hatırlatır. Engellemez.
- `.github/workflows/copilot-setup-steps.yml` — Copilot coding agent ortamına
  bağımlılıkları önceden kurar.
- `.vscode/settings.json` — agent mode için terminal komut allowlist/denylist'i
  (`chat.tools.terminal.autoApprove`). Global `chat.tools.autoApprove` asla
  açılmaz — onay mekanizmasını tamamen kapatır.
- Guardrail zinciri: hook → lokal kalite kapıları → CI → review. Hook'lar
  kolaylık katmanıdır; zorlama kapılarda ve CI'dadır.
