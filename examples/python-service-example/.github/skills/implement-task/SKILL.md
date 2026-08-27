---
name: implement-task
description: Bir task.md dosyasını uçtan uca uygular — görevi oku, geliştir, test et, öz-incele, PR aç. Bir görev dosyası veya ticket verildiğinde kullan (ör. "TASK-123'ü uygula"). Zorunlu alanlar (kabul kriterleri, DoD, nasıl test edilir, veri kaynakları) eksikse durur ve sorar; gereksinim uydurmaz.
---

# Bir görevi uygula

> Altın kural: sessiz varsayım yok. Görevdeki her belirsizlik sorulur,
> uydurulmaz (AGENTS.md kural #1).

## 1. Görevi oku

`task.md` dosyasını oku. Şunları taşıdığını doğrula: bağlam, kapsam
(içinde/dışında), ölçülebilir kabul kriterleri, DoD, nasıl test edilir ve veri
söz konusuysa veri kaynakları (DB/tablo/kolon). **Biri bile eksikse dur ve
görevin yazarına sor.**

## 2. Bağlamı topla

Görevin dokunduğu dokümanları oku:
[conventions.md](../../../docs/engineering/conventions.md),
[architecture.md](../../../docs/engineering/architecture.md), ilgili ADR'lar ve
domain dokümanları. Yeni kod yazmadan önce yeniden kullanılabilecek mevcut
modül/yardımcıları ara.

## 3. Dal aç

Taze main'den: `<tip>/<kebab-aciklama>` (conventional-commit tipi), ör.
`feat/TASK-123-export-endpoint`.

## 4. Geliştir

Kabul kriterlerini karşılayan en küçük diff. Yeni endpoint'ler `new-endpoint`
skill'i ile; şema değişiklikleri `db-migration` ile; dış girdiyi sınırda
doğrula. Yol boyunca bir karar netleşirse, devam etmeden önce
`record-decision` çalıştır.

## 5. Doğrula

- Yeni davranış → en az bir test; hata düzeltmesi → önce başarısız test,
  sonra düzeltme.
- Endpoint değişiklikleri → endpoint'i lokalde çağır ve gerçek yanıtı kontrol et.
- Görevin kendi "nasıl test edilir" adımlarını uygula.

## 6. Kapılar + öz-inceleme

`run-quality-gates` çalıştır; istersen diff üzerinde `simplify` koş (yeniden kullanım/ölü ağırlık temizliği), ardından `self-review`. Kritik/orta bulguları düzelt.

## 7. PR

Conventional-commit formatında PR başlığı. Açıklama: ne değişti, nasıl
doğrulandı, öz-inceleme ne buldu, hangi kabul kriterleri karşılandı. Görevin
DoD listesini işaretle.
