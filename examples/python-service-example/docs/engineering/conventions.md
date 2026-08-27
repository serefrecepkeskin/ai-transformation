# Konvansiyonlar

> Buraya yalnızca araçların (ruff/mypy) zaten zorlamadığı kurallar girer.

## Genel

- Public fonksiyonlarda tam tip ipuçları; `Any` yalnızca yazılı gerekçeyle.
- Format/lint: ruff (line-length 100, isort dahil); konfig `pyproject.toml`.
- Commit & PR: İngilizce conventional-commit başlık, Türkçe gövde/açıklama
  (`commit-and-pr` skill'i); PR başlığı squash commit olur. commitlint henüz yok.

## Yapı & isimlendirme

- Katman sırası: `api/routes` → `services` → `models`; router asla doğrudan
  ORM modeli döndürmez, her yanıt `schemas/`'taki bir Pydantic modelidir.
- Modüller snake_case; şema sınıfları `OrderCreate` / `OrderRead` /
  `OrderUpdate` kalıbında; servis fonksiyonları fiille başlar (`create_order`).
- Router dosyası kaynağın çoğul adıdır (`orders.py`), prefix `/orders`.

## Sınırlar & hatalar

- Dış girdi kenarda Pydantic ile doğrulanır; servisler dict değil şema/model alır.
- Hata kontratı: `app/main.py`'deki exception handler'lar RFC 7807 benzeri
  `{"type","title","detail"}` JSON'u döndürür; servisler `DomainError`
  türevleri fırlatır (`OrderStateError`, `NotFoundError`).
- Secret/konfig yalnız `app/settings.py` üzerinden; `os.environ` inline yasak.

## Veri erişimi

- Session, request başına dependency ile açılır; servis kendi session'ını
  yaratmaz. Transaction sınırı = servis fonksiyonu.
- SQL string birleştirme yasak; şema değişiklikleri yalnız Alembic ile
  (`db-migration` skill'i).

## Loglama & gözlemlenebilirlik

- `structlog` JSON çıktı; her request'e middleware'de `request_id` bağlanır.
- Asla loglanmaz: müşteri ad/e-posta/adres alanları, ödeme bilgisi.

## Dallanma & PR'lar

- Dal adları: conventional-commit tipiyle `<tip>/<kebab-aciklama>`.
- PR başlığı: geçerli conventional commit (squash commit'i o olur).
- Sürüm otomasyonu yok; imaj etiketi = kısa commit SHA'sı.

## Otomatik guardrail'ler (Copilot hook'ları & onaylar)

- `.github/hooks/format-and-docs.json` — **postToolUse** değişen Python
  dosyalarını otomatik formatlar (ruff format + ruff check --fix);
  **agentStop** kod değişip `docs/` değişmediğinde ya da bağımlılık ADR'sız
  değiştiğinde hatırlatır. Engellemez.
- `.github/workflows/copilot-setup-steps.yml` — agent ortamına uv + Python
  3.12 + bağımlılıkları kurar.
- `.vscode/settings.json` — güvenli komutlara otomatik onay
  (`chat.tools.terminal.autoApprove`); global `chat.tools.autoApprove` kapalı.
- Guardrail zinciri: hook → lokal kalite kapıları → CI → review.
