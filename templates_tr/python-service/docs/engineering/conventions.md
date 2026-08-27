# Konvansiyonlar

> **PLACEHOLDER** — TODO'ları bu kod tabanında gerçekten gözlemlenen
> konvansiyonlarla değiştirmek için `bootstrap-research` skill'ini çalıştır.
> Buraya yalnızca araçların (linter/formatter) zaten zorlamadığı kurallar girer.

## Genel

- Public fonksiyonlarda tam tip ipuçları; `Any` yalnızca yazılı gerekçeyle.
- Format/lint: TODO(confirm) (araç + konfig).
- Commit & PR: İngilizce conventional-commit başlık, Türkçe gövde/açıklama —
  bkz. `commit-and-pr` skill'i. TODO(confirm): nasıl zorlanıyor (commitlint?).

## Yapı & isimlendirme

- Modül/paket yerleşim kuralları: TODO (router, servis, model nerede yaşıyor).
- İsimlendirme: TODO (snake_case modüller, model son ekleri vb. gözlemlendiği gibi).

## Sınırlar & hatalar

- Dış girdi kenarda doğrulanır (tipli request modelleri); içeride ham dict
  değil tipli nesneler dolaşır.
- Hata kontratı: TODO (exception hiyerarşisi, hata yanıt şekli, loglama).
- Secret/konfig yalnız settings katmanından — satır arasında `os.environ` yok,
  commit'lenmiş değer yok.

## Veri erişimi

- TODO: session/transaction yönetim deseni; string birleştirmeyle SQL yok;
  şema değişiklikleri yalnız migration ile (`db-migration` skill'i).

## Loglama & gözlemlenebilirlik

- TODO(confirm): logger kullanımı, correlation id'ler, asla loglanmaması
  gerekenler (PII).

## Dallanma & PR'lar

- Dal adları: conventional-commit tipiyle `<tip>/<kebab-aciklama>`.
- PR başlığı: geçerli conventional commit (squash commit'i o olur).
- TODO(confirm): bu commit'leri okuyan bir sürüm otomasyonu var mı.

## Otomatik guardrail'ler (Copilot hook'ları & onaylar)

- `.github/hooks/format-and-docs.json` — **postToolUse** değişen Python
  dosyalarını otomatik formatlar (ruff format + ruff check --fix);
  **agentStop** kod değişip `docs/` değişmediğinde (drift) ya da bağımlılık
  ADR'sız değiştiğinde hatırlatır. Engellemez.
- `.github/workflows/copilot-setup-steps.yml` — Copilot coding agent ortamına
  bağımlılıkları önceden kurar.
- `.vscode/settings.json` — agent mode için terminal komut allowlist/denylist'i
  (`chat.tools.terminal.autoApprove`). Global `chat.tools.autoApprove` asla
  açılmaz — onay mekanizmasını tamamen kapatır.
- Guardrail zinciri: hook → lokal kalite kapıları → CI → review. Hook'lar
  kolaylık katmanıdır; zorlama kapılarda ve CI'dadır.
