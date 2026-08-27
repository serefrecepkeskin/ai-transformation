---
name: create-task
description: Şirket şablonundan bir geliştirme görevi (task.md) yazar — bağlam, kapsam, ölçülebilir kabul kriterleri, DoD, nasıl test edilir, doğrulanmış veri kaynakları. Analist bir iş ihtiyacını teslim edilebilir bir göreve dönüştürmek istediğinde kullan. Bilemeyeceklerini sorar; gereksinim ya da alan adı uydurmaz.
---

# Görev oluştur

Çıktı: [task-template.md](../../../docs/task-template.md) formatına birebir
uyan `tasks/<ID>-<kebab-baslik>.md` dosyası.

## Adımlar

1. **İhtiyacı anla.** Analistin anlatımından problemi tek paragrafta yeniden
   ifade et ve onaylat. Şunları sor: hedef depo, öncelik, tarih baskısı —
   bunları asla tahmin etme.
2. **Veriyi doğrula.** Görevin dokunacağı her tablo/kolon için `db-research`
   skill'ini çalıştır. "Doğrulanma tarihi" olmayan bir veri referansı göreve
   girmez. Tekrar araştırmamak için önce
   [db-catalog.md](../../../docs/db-catalog.md) dosyasına bak.
3. **Taslakla.** Zorunlu her bölümü doldur:
   - Kabul kriterleri: ölçülebilir, mümkünse given/when/then. Her muğlak
     istek ("hızlı", "kullanıcı dostu") bir sayıya ya da gözlemlenebilir bir
     duruma çevrilir.
   - Kapsam: **Dışında** listesini yaz — bu görev neyi bilinçli olarak kapsamıyor.
   - Nasıl test edilir: bir geliştirici ajanının aynen uygulayabileceği adımlar.
   - DoD: [definition-of-done.md](../../../docs/definition-of-done.md)
     temelinden başla, göreve özel maddeleri ekle.
4. **Bilinmeyenleri etiketle.** Analistin doğrulayamadığı her şey gövdeye
   gerçek gibi değil, sahibiyle birlikte "Açık sorular" bölümüne girer.
5. **Kapıdan geçir.** Taslak üzerinde `refine-task` skill'ini çalıştır ve
   görevi hazır diye sunmadan önce bulgularını düzelt.

## Kurallar

- Görevin hiçbir yerinde PII veya gerçek müşteri değeri olmaz (AGENTS.md kural #2).
- Görev başına tek çıktı; kriterler ekranı taşırıyorsa bölmeyi öner.
