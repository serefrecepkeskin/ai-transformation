---
name: run-quality-gates
description: Deponun kalite kapılarını çalıştırır — lint, tip kontrolü ve test paketi — ve her kapı için geçti/kaldı raporlar. Her commit/PR öncesi ve bulguları düzelttikten sonra yeşili doğrulamak için kullan.
---

# Kalite kapılarını çalıştır

Bu deponun kapıları (CI ile birebir aynı):

1. Lint: `uv run ruff check .`
2. Format kontrolü: `uv run ruff format --check .`
3. Tip kontrolü: `uv run mypy app`
4. Testler: `uv run pytest` (integration için Docker gerekir; hızlı döngüde
   `uv run pytest tests/unit`)

## Kurallar

- Sonucu kapı kapı raporla; başarısızlıkta çıktıyı alıntıla ve **düzelt**,
  sonra o kapıyı tekrar çalıştır. Geçtiğini görmeden asla yeşil raporlama.
- Kapıyı geçmek için kapıyı zayıflatma (test atlamak, gelişigüzel
  `# type: ignore` / `# noqa` serpmek) — açık bir insan kararı olmadan
  yapılmaz, ki o da bir ADR gerektirir.
