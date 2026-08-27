---
name: record-decision
description: Bir mimari/araç/domain kararını kalıcı olarak kaydeder — docs/decisions/ altında sıradaki numaralı ADR'ı oluşturur, indeksi ve etkilenen engineering/domain dokümanını günceller. Bir framework/kütüphane seçimi, klasör/mimari deseni, domain kuralı yorumu ya da geri dönüşü pahalı bir yön netleştiği anda kullan — kod henüz değişmemiş olsa bile.
---

# Karar kaydet (ADR)

**Proaktif tetikle.** Hızlı test: "yeni gelen bir takım arkadaşı *bu neden
böyle yapılmış* diye sorar mı?" — cevap evetse kaydet. Emin değilsen
kaydetmekten yana kullan.

## Adımlar

1. Sıradaki numarayı bul: `docs/decisions/` içindeki en yüksek `NNNN` + 1.
2. Aşağıdaki şablonla `docs/decisions/NNNN-kebab-baslik.md` dosyasını yaz.
3. `docs/decisions/README.md` içindeki indeks tablosuna satırı ekle.
4. Eski bir ADR'ın yerini alıyorsa, o ADR'ı `NNNN tarafından geçersiz kılındı`
   olarak işaretle.
5. Etkilenen dokümanı (`docs/engineering/` veya `docs/domain/`) **aynı PR
   içinde** güncelle — dokümanlar ve kod birbirinden kopmamalı.

## ADR şablonu

```markdown
# ADR NNNN — <Başlık>

- **Durum:** Kabul edildi
- **Tarih:** YYYY-AA-GG
- **Karar verenler:** <kim>

## Bağlam

<problem ve etkileyen faktörler — kısa>

## Karar

<somut olarak ne kararlaştırıldı>

## Alternatifler

<neler değerlendirildi ve neden elendi — kısa>

## Sonuçlar

<ne kolaylaşıyor, ne zorlaşıyor; takip işleri>
```
