---
name: db-migration
description: Bir veritabanı şema migration'ını güvenle oluşturur ve uygular — projenin migration aracıyla üretilmiş, incelenmiş, geri alınabilir, test edilmiş. Her şema değişikliği için kullan; migration olmadan veritabanını ya da modelleri değiştirme.
---

# Veritabanı migration'ı

Bu depoda araç **Alembic**tir: üretim `uv run alembic revision --autogenerate
-m "<özet>"`, uygulama `uv run alembic upgrade head`, geri alma
`uv run alembic downgrade -1`. Migration'lar `alembic/versions/` altındadır.

## Adımlar

1. Önce ORM modellerini değiştir; migration'ı projenin aracıyla üret
   (ör. `alembic revision --autogenerate -m "<özet>"`).
2. **Üretilen dosyayı oku** — autogenerate yeniden adlandırmaları ve
   kısıtları kaçırır; düzeltmeyi migration içinde yap, veritabanını elle
   düzenleme.
3. Çalışan bir downgrade yolu olduğunu doğrula (ya da neden geri alınamaz
   olduğunu migration'ın docstring'ine ve PR'a yaz).
4. Lokalde uygula, test paketini çalıştır ve etkilenen endpoint'leri dene.
5. Yıkıcı işlemler (veri içeren kolonu düşürme/yeniden adlandırma) → önce dur
   ve açık bir insan onayı al; PR'da belirt.

## Kurallar

- Mümkünse PR başına tek migration; alakasız şema değişikliklerini asla karıştırma.
- Veri doldurmaları ayrı ve idempotent migration/script'lerdir.
