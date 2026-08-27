---
name: run-quality-gates
description: Deponun kalite kapılarını çalıştırır — lint, tip kontrolü ve test paketi — ve her kapı için geçti/kaldı raporlar. Her commit/PR öncesi ve bulguları düzelttikten sonra yeşili doğrulamak için kullan.
---

# Kalite kapılarını çalıştır

Her kapıyı AGENTS.md'nin Komutlar bölümünden çalıştır (PLACEHOLDER —
bootstrap-research sonrası bunlar deponun gerçek komutları olur):

1. Lint (ör. `ruff check .`)
2. Format kontrolü (ör. `ruff format --check .`)
3. Tip kontrolü (ör. `mypy .`)
4. Testler (ör. `pytest`)

## Kurallar

- Sonucu kapı kapı raporla; başarısızlıkta çıktıyı alıntıla ve **düzelt**,
  sonra o kapıyı tekrar çalıştır. Geçtiğini görmeden asla yeşil raporlama.
- Kapıyı geçmek için kapıyı zayıflatma (test atlamak, gelişigüzel
  `# type: ignore` / `# noqa` serpmek) — açık bir insan kararı olmadan
  yapılmaz, ki o da bir ADR gerektirir.
