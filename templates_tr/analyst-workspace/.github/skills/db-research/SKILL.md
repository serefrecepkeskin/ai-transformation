---
name: db-research
description: MCP veritabanı bağlantıları üzerinden salt okunur şema ve veri-şekli keşfi — görevler ve katalog için alıntılanabilir kanıt üretir (db.şema.tablo.kolon + doğrulama tarihi). Bir görevin veri referanslarının doğrulanması ya da "X nerede tutuluyor?" sorusunun yanıtlanması gerektiğinde kullan.
---

# Veritabanı araştırması (salt okunur)

> Önce katı kurallar: yalnız SELECT, hiçbir artifact'a PII değeri girmez,
> replika tercih edilir, örneklerde her zaman LIMIT/TOP (AGENTS.md kural #1-2).

## Adımlar

1. **Önce katalog.** [db-catalog.md](../../../docs/db-catalog.md) dosyasına bak —
   cevap zaten doğrulanmış olabilir. Yalnızca kataloğun bilmediği ya da
   eskimiş görünen şey için veritabanına git.
2. **Veriden önce şema.** Adayları körlemesine örnekleyerek değil, metadata
   üzerinden bul (`INFORMATION_SCHEMA.TABLES/COLUMNS` ya da motorun eşdeğeri).
   Tipleri ve null olabilirliği not et.
3. **İnsanları değil, şekli örnekle.** Format, enum, null oranı ve tarih
   konvansiyonlarını anlamak için küçük örnekler (`TOP 10`/`LIMIT 10`).
   *Deseni* kaydet ("durum ∈ {A,P,C}; ~%12 NULL"), asla gerçek kimlik
   belirleyici değerleri.
4. **Join yolunu doğrula.** Görev birden fazla tabloya yayılıyorsa, join
   anahtarlarının gerçekten eşleştiğini (tip ve değer olarak) sınırlı bir
   sorguyla doğrula.
5. **Alıntıla.** Her bulgu şu forma dönüşür: `db.şema.tablo.kolon — anlamı —
   doğrulanma tarihi YYYY-AA-GG`. Bir görev yalnızca bu formu referans alabilir.
6. **Geri işle.** `update-db-catalog` çalıştır ki bir sonraki araştırma daha
   ileriden başlasın.

## Notlar

- Prodüksiyon birincil sunucusunda pahalı bir sorgu araştırma değil, olaydır:
  her sorguyu sınırla, tam tarama yapma, sorgu uzun sürüyorsa durdur.
- Gereken bir veritabanına erişim yoksa, bunu platform ekibi için engelleyici
  olarak raporla — etrafından dolaşma.
