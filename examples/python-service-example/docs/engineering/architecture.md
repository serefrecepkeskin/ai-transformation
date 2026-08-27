# Mimari

> Kısa tut; bir mimari karar değiştiğinde bu dosyayı güncelle ve aynı PR'da
> bir ADR yaz.

## Servisin şekli

Tek FastAPI API servisi (async). Giriş noktası `app/main.py`; uvicorn ile
koşar. Docker imajı (multi-stage, python:3.12-slim) şirket container
platformunda; test ortamı her merge'de otomatik, prod manuel terfi.
Arka plan işçisi yok — uzun işler şimdilik yok (tetikleyici oluşursa ADR ile
kuyruk eklenir, bkz. tech-stack "Ertelenen").

## Paket yapısı

```
app/
├── main.py            # FastAPI app + router kayıtları + exception handler'lar
├── settings.py        # pydantic-settings; tüm konfig/secret'lar buradan
├── db.py              # async engine + session factory (request başına session)
├── api/routes/        # HTTP katmanı: orders.py, customers.py, health.py
├── schemas/           # Pydantic request/response modelleri (sınır sözleşmesi)
├── models/            # SQLAlchemy ORM modelleri: order.py, customer.py
└── services/          # domain mantığı: orders.py, customers.py
alembic/               # migration'lar (versions/)
tests/                 # unit / integration / contract / smoke (bkz. testing.md)
```

## Katmanlar

- **API / router'lar** — `app/api/routes/*`; yalnız HTTP kaygıları: Pydantic
  şemayla doğrula, servisi çağır, yanıt şemasına eşle. İş kuralı içermez.
- **Servisler** — `app/services/*`; iş kuralları burada (durum geçişleri,
  toplam hesaplama). Router'dan bağımsız test edilir.
- **Veri erişimi** — SQLAlchemy 2.0 async; session `db.py`'deki dependency ile
  request başına açılır, servislere enjekte edilir. Repository katmanı yok
  (bilinçli: servisler doğrudan session kullanır, ADR 0002).
- **Konfig & secret'lar** — `app/settings.py` (pydantic-settings, env'den);
  kod içinde `os.environ` okuma yasak.

## Dış entegrasyonlar

- **PostgreSQL 16** — tek veritabanı (`orders`), migration'lar Alembic ile.
- **Ödeme sağlayıcısı** — henüz bağlı değil; `PAID` geçişi şimdilik BFF'ten
  gelen onayla yapılıyor (bkz. manual-actions: sandbox anahtarı bekleniyor).
- Servis dışarıya çağrı yapmadığı için devre kesici/retry katmanı yok.

## Dağıtım & sürüm

Trunk-based: `main` tek kalıcı dal, PR'lar squash-merge. PR başlığı
conventional commit; CI (`ci.yml`) ruff + mypy + pytest koşar. Merge sonrası
test ortamı otomatik yeniden kurulur; prod, platform arayüzünden manuel
terfidir. Sağlık ucu: `GET /health`.
