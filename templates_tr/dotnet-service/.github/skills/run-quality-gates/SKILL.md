---
name: run-quality-gates
description: Deponun kalite kapılarını çalıştırır — build (uyarılar hata sayılır), format kontrolü ve test paketi — ve her kapı için geçti/kaldı raporlar. Her commit/PR öncesi ve bulguları düzelttikten sonra yeşili doğrulamak için kullan.
---

# Kalite kapılarını çalıştır

Her kapıyı AGENTS.md'nin Komutlar bölümünden çalıştır (PLACEHOLDER —
bootstrap-research sonrası bunlar deponun gerçek komutları olur):

1. Build (ör. `dotnet build -warnaserror`)
2. Format kontrolü (ör. `dotnet format --verify-no-changes`)
3. Testler (ör. `dotnet test`)
4. Ayrı konfigüre edilmişse analyzer'lar (TODO(confirm))

## Kurallar

- Sonucu kapı kapı raporla; başarısızlıkta çıktıyı alıntıla ve **düzelt**,
  sonra o kapıyı tekrar çalıştır. Geçtiğini görmeden asla yeşil raporlama.
- Kapıyı geçmek için kapıyı zayıflatma (test atlamak,
  `#pragma warning disable`, nullability'yi susturan `!`) — açık bir insan
  kararı olmadan yapılmaz, ki o da bir ADR gerektirir.
