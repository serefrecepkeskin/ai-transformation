---
name: new-endpoint
description: Bu deponun konvansiyonlarına uyan yeni bir API endpoint'i ekler — router yerleşimi, request/response modelleri, sınırda doğrulama, hata kontratı, testler. Bir görev yeni ya da değişen bir HTTP endpoint'i istediğinde kullan.
---

# Yeni endpoint

Önce [conventions.md](../../../docs/engineering/conventions.md) ve
[architecture.md](../../../docs/engineering/architecture.md) dosyalarını oku.
Bu depoda endpoint'ler `app/api/routes/<çoğul-kaynak>.py` dosyalarında yaşar
(prefix = `/<çoğul-kaynak>`); request/response modelleri `app/schemas/`,
iş mantığı `app/services/` içindedir. Örnek almak için `orders.py`'a bak.

## Kurallar

- **Yerleşim** — mevcut router/modül yapısına uy (dosya oluşturmadan önce
  komşu bir endpoint'e bak).
- **Önce kontrat** — tipli request/response modelleri tanımla; tüm dış girdiyi
  sınırda doğrula (kural #8). Ham dict geçişi yok.
- **Hatalar** — projenin hata kontratını kullan; istemciye asla stack trace
  veya iç mesaj sızdırma.
- **Veri erişimi** — mevcut repository/service katmanı üzerinden; string
  birleştirmeyle SQL yok; şema değişiklikleri `db-migration` skill'i ile.
- **Yetkilendirme** — BFF'ten gelen servis token'ı `require_service_auth`
  dependency'siyle doğrulanır; komşu endpoint'lerle aynı dependency kullanılır.
- **Testler** — kabul kriteri başına en az bir test, bir hata durumu dahil
  (hatalı girdi → beklenen hata şekli).
- **Doğrula** — bitti demeden önce endpoint'i lokalde çağır ve gerçek yanıtı
  kontrol et.
