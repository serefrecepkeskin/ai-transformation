---
name: update-db-catalog
description: Doğrulanmış db-research bulgularını docs/db-catalog.md dosyasına işler — veritabanı tablosunu ve veritabanı başına bölümleri taze doğrulama tarihleriyle günceller, kayıtları tekrarlamadan. Yeni bir şey öğrenilen her db-research oturumundan sonra kullan.
---

# Veritabanı kataloğunu güncelle

Yeni, **doğrulanmış** bulguları
[db-catalog.md](../../../docs/db-catalog.md) dosyasına birleştir.

## Adımlar

1. Oturumun bulgularını alıntı formunda topla
   (`db.şema.tablo.kolon — anlamı — doğrulanma tarihi`).
2. Her biri için: katalog zaten kapsıyorsa anlamı ve doğrulanma tarihini
   tazele; kapsamıyorsa doğru veritabanının bölümüne ekle (veritabanı katalog
   için yeniyse bölümü oluştur).
3. Keşfedilen tuhaflıkları ve join yollarını kaydet — gelecekteki araştırma
   zamanından en çok bunlar tasarruf ettirir.
4. Yalnız şema tut: satır değeri yok, PII yok, kimlik bilgisi yok
   (AGENTS.md kural #2).
5. Bitirmeden önce diff'i analiste göster.

## Kurallar

- Yalnızca bu oturumda doğrulanan bulgular yeni tarih alır — gerçekten
  yeniden kontrol edilmemiş bir şeyin tarihini asla ilerletme.
- Katalog bir referanstır, döküm değil: var olan her kolon için değil,
  *önemli* olan her tablo/kolon için tek satır.
