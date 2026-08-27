# Analistler Artık Nasıl Çalışıyor

Eski yöntem: ticket'ta bir paragraf niyet, hafızadan yazılmış alan adları,
geliştiriciler beklerken haftalara yayılan netleştirme toplantıları. Bu,
yapay zeka destekli geliştirmede ayakta kalmaz — ajan, kendisine verilen ne
ise onu büyütür; belirsizlik dahil.

## Yeni sözleşme

**Analist bir fikir değil, hazır bir görev teslim eder.** "Hazır" olmanın
tanımı görev şablonunda yazılıdır: ölçülebilir kabul kriterleri, DoD, nasıl
test edilir, doğrulanmış veri kaynakları. `refine-task` skill'i kapıdır;
oradan geçemeyen görev teslim edilmez.

## Döngü

1. **Önce araştır.** Görevin kullanacağı her tablo/kolonu `db-research` ile
   doğrula. Hatırlamak değil, tarihli kanıt.
2. **Ajanla taslakla.** `create-task` çalıştır — ajan şablondan taslak yazar
   ve bilemeyeceklerini sorar (öncelik, iş niyeti, tarihler). Cevapla;
   tahmin etmesine izin verme.
3. **Rafine et.** `refine-task` çalıştır. Her bulguyu düzelt: ölçülemez
   kriterler, eksik test adımları, doğrulanmamış varsayımlar.
4. **Teslim et.** Görev dosyasını commit'le; ID'yi geliştirici ekibine ver.
5. **Döngüde kal.** Geliştirici soruları yazara döner — cevabı **görev
   dosyasını güncelleyerek** ver ki kalıcı olsun.

## İlkeler

- **Ölçülebilir değilse sayılmaz.** "Liste hızlı olmalı" → "liste 1.000 satırla
  2 saniyenin altında render olmalı".
- **Küçük görevler akar, büyük görevler tıkanır.** Görev başına tek çıktı;
  kriterleri tek ekrana sığmayanı böl.
- **Varsayımlar etiketlenir.** Doğrulanmamış kurallar, sahibi ve tarihiyle
  "Açık sorular" bölümüne girer — asla gerçek gibi yazılmaz.
- **Hız tamlıktan gelir.** Her eksik alan, sonradan sana dönecek bir
  gidip-gelmedir. Yavaş olan kısım hiçbir zaman yazmak değildi; ileri geri
  konuşmaktı.
- **Veriyi koru.** Salt okunur erişim, hiçbir artifact'ta PII yok
  (AGENTS.md kural #1-2).
