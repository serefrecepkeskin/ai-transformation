# Veritabanı Kataloğu — hangi veritabanında ne var

> `update-db-catalog` skill'i tarafından, doğrulanmış `db-research`
> bulgularından derlenir. Her satır bir "doğrulanma tarihi" taşır; eskimiş
> satırları hipotez say. Buraya **asla** gerçek veri değeri yazılmaz —
> yalnızca şema.

## Veritabanları

| Ad   | Motor      | Ortam             | Ne tutuyor | Salt okunur erişim | Sahip ekip |
| ---- | ---------- | ----------------- | ---------- | ------------------ | ---------- |
| TODO | SQL Server | TODO (replika?)   | TODO       | mcp: `mssql`       | TODO       |
| TODO | PostgreSQL | TODO              | TODO       | mcp: `postgres`    | TODO       |
| TODO | Oracle     | TODO              | TODO       | mcp: `oracle`      | TODO       |
| TODO | MySQL      | TODO              | TODO       | mcp: `mysql`       | TODO       |

## Veritabanı başına kilit alanlar

### <veritabanı adı> (TODO)

- **Doğrulanma tarihi:** TODO
- **Önemli şemalar/tablolar:** TODO — `şema.tablo`: tek satır anlamı
- **Tuhaflıklar:** TODO — soft delete var mı? durum enum'ları? zaman
  damgalarının saat dilimi? "null olabilir ama aslında zorunlu" kolonlar?
- **Önemli join'ler:** TODO — çekirdek varlıklar nasıl bağlanıyor

<!-- araştırma biriktikçe her veritabanı için bu bölüm tekrarlanır -->
