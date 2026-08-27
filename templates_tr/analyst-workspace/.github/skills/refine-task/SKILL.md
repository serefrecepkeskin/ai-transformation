---
name: refine-task
description: Bir task.md için hazır olma denetimi — zorunlu bölümleri, kabul kriterlerinin ölçülebilirliğini, doğrulanmış veri kaynaklarını ve etiketlenmemiş varsayımları kontrol eder; sıralı bulgular döndürür. Her görev teslimi öncesi ya da geliştirici bir görevi geri gönderdiğinde kullan.
---

# Görevi rafine et (hazır olma denetimi)

Verilen `tasks/*.md` dosyasını kontrol listesine göre denetle. Bulguları önem
sırasına göre döndür; **engelleyici** taşıyan bir görev teslim edilemez.

## Kontrol listesi

**Engelleyiciler**

- Zorunlu bir şablon bölümü eksik veya boş (bağlam, kapsam, kabul kriterleri,
  nasıl test edilir, DoD; veri söz konusuysa veri kaynakları).
- Bir kabul kriteri kontrol edilebilir değil ("düzgün çalışmalı", "kullanıcı
  dostu", sayı verilmeden "hızlı").
- Bir veri referansının (db/şema/tablo/kolon) doğrulanma tarihi yok ya da
  [db-catalog.md](../../../docs/db-catalog.md) ile çelişiyor.
- Bir varsayım "Açık sorular" altında listelenmek yerine gerçek gibi yazılmış.
- Görevin herhangi bir yerinde gerçek müşteri verisi / PII var.

**Uyarılar**

- Kapsamda **Dışında** listesi yok.
- Nasıl test edilir bölümü, kriterlerin ima ettiği uç/hata durumlarını atlıyor.
- Görev birden fazla çıktıyı bir arada taşıyor — bölmeyi öner.
- Açık sorunun sahibi belirtilmemiş.
- Arayüz görevi olduğu halde arayüz/i18n notları yok.

## Çıktı

Bulgu başına tek satır: `bölüm · engelleyici|uyarı · sorun · somut düzeltme`.
Sonra karar: **HAZIR** ya da **HAZIR DEĞİL (n engelleyici)**. Mekanik
düzeltmeleri uygulamayı teklif et; içeriğe dair olanları analist yanıtlar.
