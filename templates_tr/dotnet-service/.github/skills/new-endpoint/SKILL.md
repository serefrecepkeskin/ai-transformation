---
name: new-endpoint
description: Bu deponun konvansiyonlarına uyan yeni bir API endpoint'i ekler — controller/minimal-API yerleşimi, DTO'lar, sınırda doğrulama, hata kontratı, testler. Bir görev yeni ya da değişen bir HTTP endpoint'i istediğinde kullan.
---

# Yeni endpoint

Önce [conventions.md](../../../docs/engineering/conventions.md) ve
[architecture.md](../../../docs/engineering/architecture.md) dosyalarını oku.
PLACEHOLDER: bootstrap-research sonrası bu skill, deponun gerçek endpoint
stilini (controller mı minimal API mı) ve DTO konvansiyonlarını yazmalı.

## Kurallar

- **Yerleşim** — mevcut controller/endpoint yapısına uy (dosya oluşturmadan
  önce komşu bir endpoint'e bak).
- **Önce kontrat** — kendine ait request/response DTO'ları; EF entity'lerini
  asla doğrudan dışarı verme. Tüm dış girdiyi sınırda doğrula (kural #8).
- **Hatalar** — projenin hata kontratını kullan (ör. ProblemDetails);
  istemciye asla stack trace veya iç mesaj sızdırma.
- **Veri erişimi** — mevcut servis/repository katmanı üzerinden; yalnız
  parametreli sorgular; şema değişiklikleri `ef-migration` skill'i ile.
- **Yetkilendirme** — komşu endpoint'lerin kullandığı aynı authorization
  policy'sini uygula; şema için TODO(confirm).
- **Uçtan uca async** — `.Result`/`.Wait()` yok; `CancellationToken` zincir
  boyunca geçirilir.
- **Testler** — kabul kriteri başına en az bir test, bir hata durumu dahil
  (hatalı girdi → beklenen hata şekli).
- **Doğrula** — bitti demeden önce endpoint'i lokalde çağır ve gerçek yanıtı
  kontrol et.
