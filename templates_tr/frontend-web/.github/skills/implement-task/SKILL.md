---
name: implement-task
description: Bir task.md dosyasını uçtan uca uygular — görevi oku, geliştir, tarayıcıda doğrula, test et, öz-incele, PR aç. Bir görev dosyası veya ticket verildiğinde kullan (ör. "TASK-123'ü uygula"). Zorunlu alanlar (kabul kriterleri, DoD, nasıl test edilir) eksikse durur ve sorar; gereksinim uydurmaz.
---

# Bir görevi uygula

> Altın kural: sessiz varsayım yok. Görevdeki her belirsizlik sorulur,
> uydurulmaz (AGENTS.md kural #1).

## 1. Görevi oku

`task.md` dosyasını oku. Şunları taşıdığını doğrula: bağlam, kapsam
(içinde/dışında), ölçülebilir kabul kriterleri, DoD, nasıl test edilir ve veri
söz konusuysa veri kaynakları. **Biri bile eksikse dur ve görevin yazarına sor.**

## 2. Bağlamı topla

Görevin dokunduğu dokümanları oku:
[conventions.md](../../../docs/engineering/conventions.md),
[architecture.md](../../../docs/engineering/architecture.md), ilgili ADR'lar ve
domain dokümanları. Yeni kod yazmadan önce yeniden kullanılabilecek mevcut
bileşen/yardımcıları ara.

## 3. Dal aç

Taze main'den: `<tip>/<kebab-aciklama>` (conventional-commit tipi), ör.
`feat/TASK-123-uygunluk-sayfasi`.

## 4. Geliştir

Kabul kriterlerini karşılayan en küçük diff. Konvansiyonlara uy; yeni arayüz
için `new-component` skill'i; kullanıcıya görünen metin i18n'den. Yol boyunca
bir karar netleşirse, devam etmeden önce `record-decision` çalıştır.

## 5. Doğrula

- Arayüz değişiklikleri → `verify-ui` skill'i (tarayıcı kanıtı: ekran
  görüntüsü, konsol, erişilebilirlik).
- Mantık değişiklikleri → testler (yeni davranış en az bir test alır; hata
  düzeltmesi önce başarısız bir test alır).
- Görevin kendi "nasıl test edilir" adımlarını uygula.

## 6. Kapılar + öz-inceleme

`run-quality-gates` çalıştır; istersen diff üzerinde `simplify` koş (yeniden kullanım/ölü ağırlık temizliği), ardından `self-review`. Kritik/orta bulguları düzelt.

## 7. PR

Conventional-commit formatında PR başlığı. Açıklama: ne değişti, nasıl
doğrulandı (tarayıcı kanıtı + testler), öz-inceleme ne buldu, hangi kabul
kriterleri karşılandı. Görevin DoD listesini işaretle.
