---
name: run-quality-gates
description: Deponun kalite kapılarını çalıştırır — typecheck, lint, format kontrolü ve test paketi — ve her kapı için geçti/kaldı raporlar. Her commit/PR öncesi ve bulguları düzelttikten sonra yeşili doğrulamak için kullan.
---

# Kalite kapılarını çalıştır

Her kapıyı AGENTS.md'nin Komutlar bölümünden çalıştır (PLACEHOLDER —
bootstrap-research sonrası bunlar deponun gerçek script'leri olur):

1. Tip kontrolü (ör. `npm run typecheck`)
2. Lint (ör. `npm run lint`)
3. Format kontrolü (ör. `npm run format:check`)
4. Birim/bileşen testleri (ör. `npm run test`)
5. Değişiklik kapsanan bir akışa dokunuyorsa E2E (ör. `npm run test:e2e`)

## Kurallar

- Sonucu kapı kapı raporla; başarısızlıkta çıktıyı alıntıla ve **düzelt**,
  sonra o kapıyı tekrar çalıştır. Geçtiğini görmeden asla yeşil raporlama.
- Kapıyı geçmek için kapıyı zayıflatma (test atlamak, lint-disable yorumu) —
  açık bir insan kararı olmadan yapılmaz, ki o da bir ADR gerektirir.
