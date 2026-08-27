# Konvansiyonlar

> **PLACEHOLDER** — TODO'ları bu kod tabanında gerçekten gözlemlenen
> konvansiyonlarla değiştirmek için `bootstrap-research` skill'ini çalıştır.
> Buraya yalnızca araçların (analyzer/formatter) zaten zorlamadığı kurallar girer.

## Genel

- Nullable referans tipleri açık; uyarıyı susturmak için yazılı gerekçe
  olmadan `!` kullanılmaz.
- Formatlama `.editorconfig` + `dotnet format` ile; TODO(confirm) analyzer seti.
- Commit & PR: İngilizce conventional-commit başlık, Türkçe gövde/açıklama —
  bkz. `commit-and-pr` skill'i. TODO(confirm): nasıl zorlanıyor (commitlint?).

## Yapı & isimlendirme

- Proje sınırları ve izin verilen bağımlılık yönleri: TODO.
- İsimlendirme: TODO (async son eki, DTO son eki, feature-bazlı mı katman-bazlı
  klasörleme — gözlemlendiği gibi).

## Sınırlar & hatalar

- Dış girdi kenarda doğrulanır (tipli DTO'lar + doğrulama); EF entity'leri API
  sınırını asla geçmez.
- Hata kontratı: TODO (ProblemDetails? exception middleware? loglama).
- Secret/konfig yalnız options deseni ve tanımlı secret kaynakları üzerinden —
  hardcoded değer yok, commit'lenmiş değer yok.

## Async & veri erişimi

- Uçtan uca async: `.Result`/`.Wait()`/`async void` yok; public async API'lerde
  `CancellationToken` zincir boyunca geçirilir.
- TODO: DbContext yaşam süresi deseni; yalnız parametreli sorgular; şema
  değişiklikleri yalnız migration ile (`ef-migration` skill'i).

## Loglama & gözlemlenebilirlik

- TODO(confirm): logger kullanımı, correlation id'ler, asla loglanmaması
  gerekenler (PII).

## Dallanma & PR'lar

- Dal adları: conventional-commit tipiyle `<tip>/<kebab-aciklama>`.
- PR başlığı: geçerli conventional commit (squash commit'i o olur).
- TODO(confirm): bu commit'leri okuyan bir sürüm otomasyonu var mı.

## Otomatik guardrail'ler (Copilot hook'ları & onaylar)

- `.github/hooks/verify-and-docs.json` — **agentStop**
  `dotnet format --verify-no-changes` kontrolü yapar; kod değişip `docs/`
  değişmediğinde (drift) ya da proje dosyaları ADR'sız değiştiğinde hatırlatır.
  Formatlama edit başına değil oturum sonunda koşar — tool çağrısı başına tüm
  solution taraması çok yavaştır. Engellemez.
- `.github/workflows/copilot-setup-steps.yml` — Copilot coding agent ortamına
  bağımlılıkları önceden kurar.
- `.vscode/settings.json` — agent mode için terminal komut allowlist/denylist'i
  (`chat.tools.terminal.autoApprove`); `dotnet ef database update` bilinçli
  olarak onaya düşer. Global `chat.tools.autoApprove` asla açılmaz.
- Guardrail zinciri: hook → lokal kalite kapıları → CI → review. Hook'lar
  kolaylık katmanıdır; zorlama kapılarda ve CI'dadır.
