# Test

> **PLACEHOLDER** — gerçek koşucuları ve CI kapılarını doldurmak için
> `bootstrap-research` skill'ini çalıştır. Aşağıdaki klasör taksonomisi şirket
> standardıdır; koru.

## Test taksonomisi (klasörler sözleşmedir)

```
tests/
├── unit/          # saf mantık (servis, mapper, validator) — I/O yok, ms hızında
├── integration/   # endpoint + DB — uygulamaya gerçek HTTP çağrısı, fixture/test container
├── contract/      # API şeması ↔ tüketiciler — yanıt şekilleri uyumlu kalır
└── smoke/         # birkaç hızlı uçtan uca kontrol — health + bir kritik yol
```

- **unit** — fonksiyon verilen girdiyle beklendiği gibi döner/hata fırlatır;
  ağ yok, veritabanı yok, dosya sistemi yok.
- **integration** — routing/doğrulama/DB üzerinden bağlanmış endpoint,
  hata yanıtları dahil beklendiği gibi davranır.
- **contract** — dokümante request/response şekilleri tüketicileri sessizce
  kırmaz (şema doğrulamaları; gerekirse consumer-driven contract'a büyür).
- **smoke** — her deploy sonrası koşacak kadar ucuz: çalışan servise karşı
  `/health` + bir kritik iş yolu.

## Hangi değişiklik hangi testi yazar

| Değişiklik                 | Asgari gereken test                                   |
| -------------------------- | ----------------------------------------------------- |
| Yeni servis/domain mantığı | unit                                                  |
| Yeni/değişen endpoint      | integration (mutlu yol + en az bir hata durumu)       |
| Yanıt şekli değişikliği    | contract                                              |
| Hata düzeltmesi            | önce başarısız test, hatayı üreten en alt katmanda    |
| Yeni kritik akış           | smoke'a ekle                                          |

## Kurallar

- **Her task en az bir test getirir**; PR, kabul kriterlerini testlerle eşler
  ("kriter 2 → `tests/integration/test_orders_api.py`").
- Hata düzeltmesi → önce hatayı yeniden üreten başarısız test, sonra düzeltme.
- Testler **çevrimdışı** koşar — dış servisler taklit/fixture ile; hiçbir test
  ağ erişimine bağımlı olamaz.
- Kapılar yeşil olmadan merge yok (bkz. `run-quality-gates`).

## Komutlar & CI

TODO(confirm): katman başına gerçek komutlar ve PR'larda hangi workflow'un
hangi kapıları koştuğu.
