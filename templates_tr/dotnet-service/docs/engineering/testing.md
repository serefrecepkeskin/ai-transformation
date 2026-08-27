# Test

> **PLACEHOLDER** — gerçek framework'leri ve CI kapılarını doldurmak için
> `bootstrap-research` skill'ini çalıştır. Aşağıdaki klasör taksonomisi şirket
> standardıdır.

## Test taksonomisi (klasörler sözleşmedir)

```
tests/
├── Unit/           # saf mantık (servis, mapper, validator) — I/O yok, ms hızında
├── Integration/    # WebApplicationFactory + gerçek DB container — pipeline'dan geçen endpoint
├── Architecture/   # bağımlılık kuralları — ör. Domain, Infrastructure'a referans veremez
└── Smoke/          # birkaç hızlı uçtan uca kontrol — health + bir kritik yol
```

- **Unit** — sınıf/metot verilen girdiyle beklendiği gibi döner/fırlatır;
  ağ yok, veritabanı yok.
- **Integration** — routing/doğrulama/EF üzerinden bağlanmış endpoint
  (gerçek DB için Testcontainers veya eşdeğeri), hata yanıtları
  (ProblemDetails şekli) dahil beklendiği gibi davranır.
- **Architecture** — proje sınırı kuralları test olarak yazılır (NetArchTest
  ya da benzeri); yasak bir referans review'da değil build'de patlar.
- **Smoke** — her deploy sonrası koşacak kadar ucuz: çalışan servise karşı
  `/health` + bir kritik iş yolu.

## Hangi değişiklik hangi testi yazar

| Değişiklik                 | Asgari gereken test                                   |
| -------------------------- | ----------------------------------------------------- |
| Yeni servis/domain mantığı | Unit                                                  |
| Yeni/değişen endpoint      | Integration (mutlu yol + en az bir hata durumu)       |
| Yeni proje/katman sınırı   | Architecture kuralı                                   |
| Hata düzeltmesi            | önce başarısız test, hatayı üreten en alt katmanda    |
| Yeni kritik akış           | Smoke'a ekle                                          |

## Kurallar

- **Her task en az bir test getirir**; PR, kabul kriterlerini testlerle eşler
  ("kriter 2 → `tests/Integration/OrdersApiTests.cs`").
- Hata düzeltmesi → önce hatayı yeniden üreten başarısız test, sonra düzeltme.
- Testler **çevrimdışı** koşar — dış servisler taklit edilir; container'lar lokaldir.
- Kapılar yeşil olmadan merge yok (bkz. `run-quality-gates`).

## Komutlar & CI

TODO(confirm): katman başına gerçek komutlar ve PR'larda hangi workflow'un
hangi kapıları koştuğu.
