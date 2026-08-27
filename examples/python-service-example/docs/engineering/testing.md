# Test

> Klasör taksonomisi şirket standardıdır; koru.

## Test taksonomisi (klasörler sözleşmedir)

```
tests/
├── unit/          # servis mantığı (durum geçişleri, toplam hesabı) — DB yok
├── integration/   # endpoint + Postgres (testcontainers) — httpx ile gerçek çağrı
├── contract/      # yanıt şemaları BFF ile uyumlu kalır (şema doğrulamaları)
└── smoke/         # /health + sipariş oluştur-oku kritik yolu (-m smoke)
```

## Hangi değişiklik hangi testi yazar

| Değişiklik                 | Asgari gereken test                                |
| -------------------------- | -------------------------------------------------- |
| Yeni servis/domain mantığı | unit                                               |
| Yeni/değişen endpoint      | integration (mutlu yol + en az bir hata durumu)    |
| Yanıt şekli değişikliği    | contract                                           |
| Hata düzeltmesi            | önce başarısız test, hatayı üreten en alt katmanda |
| Yeni kritik akış           | smoke'a ekle                                       |

## Komutlar

- `uv run pytest` — tüm paket (integration testleri Docker ister:
  testcontainers Postgres 16 açar)
- `uv run pytest tests/unit` — hızlı döngü
- `uv run pytest -m smoke` — smoke alt kümesi (deploy sonrası da koşar)

## Kurallar

- **Her task en az bir test getirir**; PR, kabul kriterlerini testlerle eşler
  ("kriter 2 → `tests/integration/test_orders_api.py`").
- Hata düzeltmesi → önce hatayı yeniden üreten başarısız test, sonra düzeltme.
- Testler **çevrimdışı** koşar — ödeme sağlayıcısı fake'tir; hiçbir test dış
  ağa çıkmaz (testcontainers lokaldir).
- Kapılar yeşil olmadan merge yok (bkz. `run-quality-gates`).

## CI

`.github/workflows/ci.yml`, her PR'da: `ruff check` + `ruff format --check` +
`mypy app` + `pytest` (testcontainers dahil). Kırmızı test merge'i engeller.
