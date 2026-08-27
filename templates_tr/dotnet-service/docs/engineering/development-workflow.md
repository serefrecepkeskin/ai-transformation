# Geliştirme Akışı

> Bir değişikliğin görevden prodüksiyona kadarki yaşam döngüsü. PLACEHOLDER
> maddeleri `bootstrap-research` doldurur; akışın kendisi şirket standardıdır.

```
task.md → dal → geliştir → doğrula → öz-inceleme → PR → CI kapıları → merge → dağıtım
```

1. **İşi al** — işler `task.md` olarak gelir (analist yazar, analist
   workspace'indeki görev şablonu). `implement-task` skill'i tüm akışı
   yürütür. Kabul kriterleri / DoD / nasıl test edilir taşımayan görev geri
   gönderilir.
2. **Dal aç** — taze main'den: `<tip>/<kebab-aciklama>`.
3. **Geliştir** — en küçük diff, konvansiyonlara uyum, sınırlarda doğrulama,
   şema değişiklikleri migration ile. Netleşen kararlar anında kaydedilir
   (`record-decision`).
4. **Doğrula** — davranış için testler, API değişiklikleri için lokal endpoint
   çağrıları; kapılar lokalde yeşil (`run-quality-gates`).
5. **Öz-inceleme** — `self-review` skill'i; kritik/orta bulguları düzelt.
6. **PR** — conventional-commit başlığı; açıklama ne değiştiğini, test kanıtını
   ve öz-inceleme sonucunu taşır.
7. **Merge & dağıtım** — TODO(confirm): squash politikası, sürüm otomasyonu,
   dağıtım hedefleri ve terfi akışı.
8. **Merge sonrası** — main'i çek, sıradaki görevi taze bir daldan başlat.
