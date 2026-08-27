# ADR 0003 — Dört katmanlı test taksonomisi

- **Durum:** Kabul edildi
- **Tarih:** 2026-08-22
- **Karar verenler:** orders-service ekibi

## Bağlam

Şirket standardı, test klasörlerinin katman mantığıyla ayrılmasını ister.
Serviste iş kuralı yoğunluğu durum geçişlerinde; en pahalı hata ise BFF'e
giden yanıt şeklinin sessizce kırılması.

## Karar

`tests/` dört katmana ayrıldı: **unit** (servis mantığı, DB'siz),
**integration** (testcontainers Postgres ile endpoint), **contract**
(yanıt şemaları BFF sözleşmesine karşı), **smoke** (`-m smoke`: /health +
sipariş oluştur-oku, deploy sonrası da koşar). Her task en az bir test
getirir; PR kabul kriterlerini testlerle eşler.

## Alternatifler

- Tek düz `tests/` klasörü — hangi testin neyi garanti ettiği görünmez oluyor,
  reddedildi.
- E2E katmanı — servis tek başına; uçtan uca akış BFF reposunda test ediliyor.

## Sonuçlar

- Integration testleri Docker ister; CI runner'ında testcontainers çalışır.
- Yanıt şeması değişikliği contract testine takılır; bilinçliyse ADR/sürümle gider.
