---
name: ef-migration
description: Bir EF Core şema migration'ını güvenle oluşturur ve uygular — üretilmiş, incelenmiş, geri alınabilir, test edilmiş. Her şema değişikliği için kullan; veritabanını ya da üretilmiş bir migration'ı asla elle düzenleme.
---

# EF Core migration'ı

PLACEHOLDER: bootstrap-research sonrası gerçek DbContext'leri, startup
projesini ve tam komutları buraya yaz.

## Adımlar

1. Önce entity modelini/konfigürasyonunu değiştir; migration'ı üret:
   `dotnet ef migrations add <Ozet> --project TODO --startup-project TODO`.
2. **Üretilen migration'ı oku** — yeniden adlandırmaları (EF bunu drop+add
   olarak görür), kısıtları ve indeks değişikliklerini kontrol et; düzeltmeyi
   migration kodunda yap, veritabanında değil.
3. `Down()` yolunun çalıştığını doğrula (ya da neden geri alınamaz olduğunu
   PR'da yaz).
4. Lokalde uygula (`dotnet ef database update`), test paketini çalıştır ve
   etkilenen endpoint'leri dene.
5. Yıkıcı işlemler (veri içeren kolonu düşürme/yeniden adlandırma) → önce dur
   ve açık bir insan onayı al; PR'da belirt.

## Kurallar

- Mümkünse PR başına tek migration; alakasız şema değişikliklerini asla karıştırma.
- Veri doldurmaları ayrı ve idempotent migration/script'lerdir.
- Prodüksiyonda uygulama stratejisi: TODO(confirm) (migration bundle / SQL
  script / otomatik migrate — pipeline gerçekte ne yapıyor?).
