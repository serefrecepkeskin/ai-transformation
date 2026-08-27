# Teknoloji Yığını (Canlı Referans)

> Bu dosya **canlıdır**: yığın değiştiğinde güncellenir, gerekçesi bir ADR
> olarak kaydedilir. Sürümler `uv.lock`'tan okunmuştur.

## Aktif yığın

| Katman                | Seçim                     | Sürüm (kurulu) |
| --------------------- | ------------------------- | -------------- |
| Dil                   | Python                    | 3.12.7         |
| Framework             | FastAPI                   | 0.115.6        |
| ORM / veri erişimi    | SQLAlchemy (async)        | 2.0.36         |
| Migration             | Alembic                   | 1.14.0         |
| Doğrulama             | Pydantic + pydantic-settings | 2.10.3 / 2.6.1 |
| Veritabanı            | PostgreSQL                | 16             |
| Lint/format           | ruff                      | 0.8.4          |
| Tip kontrolü          | mypy (strict)             | 1.13.0         |
| Test                  | pytest + httpx            | 8.3.4 / 0.28.1 |
| Bağımlılık yöneticisi | uv                        | 0.5.11         |

## Ertelenen (tetikleyici oluşunca ekle)

| Madde                      | Tetikleyici koşul                                          |
| -------------------------- | ---------------------------------------------------------- |
| Görev kuyruğu (arq/Celery) | 5 sn'yi aşan bir iş request içinde yapılmak zorunda kalırsa |
| Redis cache                | Aynı sorgu için DB yükü ölçülüp sorun olduğunda            |
| OpenTelemetry              | Servis sayısı artıp iz sürme ihtiyacı somutlaşınca         |

## Bilinçli dışarıda bırakılanlar

| Madde              | Gerekçe                                                    |
| ------------------ | ---------------------------------------------------------- |
| Repository katmanı | Tek DB, basit sorgular; SQLAlchemy session yeterli (ADR 0002) |
| Django             | Tek API servisi için tam framework fazla; FastAPI seçildi (ADR 0002) |
