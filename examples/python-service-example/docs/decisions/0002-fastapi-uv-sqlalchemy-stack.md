# ADR 0002 — FastAPI + uv + SQLAlchemy yığını

- **Durum:** Kabul edildi
- **Tarih:** 2026-08-21
- **Karar verenler:** orders-service ekibi

## Bağlam

Sipariş servisi tek bir async API servisidir: CRUD + durum geçişleri, tek
PostgreSQL veritabanı, tüketicisi BFF. Ekip Python'da; hızlı geliştirme
döngüsü ve sıkı tip disiplini isteniyor.

## Karar

- **FastAPI** (Pydantic ile sınır doğrulaması bedavaya gelir, async yerli).
- **uv** bağımlılık yöneticisi (hızlı, tek lockfile, CI'da aynı araç).
- **SQLAlchemy 2.0 async + Alembic**; repository katmanı YOK — servisler
  session'ı doğrudan kullanır. Tek DB ve basit sorgularla ek soyutlama
  maliyetine değmez; sorgu karmaşıklığı artarsa yeni ADR ile eklenir.

## Alternatifler

- Django + DRF — tam framework; admin/ORM paketine ihtiyaç yok, reddedildi.
- Litestar — olgunluk ve ekip aşinalığı gerekçesiyle FastAPI tercih edildi.
- poetry — uv'nin hız ve tek-araç avantajına yenildi.

## Sonuçlar

- Yanıt modelleri her zaman Pydantic şemasıdır; ORM modeli sınırı geçmez.
- Şema değişiklikleri yalnız Alembic migration'ı ile yapılır.
