# TASK-001 — Admin kullanıcı listesinde son giriş tarihini göster

> **ÖRNEK görev** — şablonun canlı örneği olarak duruyor. Gerçek görevler
> birebir bu şekli takip eder.

- **Yazar:** A. Analist (ekip kanalından ulaşılabilir)
- **Tarih:** 2026-08-26
- **Hedef depo:** admin-portal (frontend)
- **Öncelik:** orta

## Bağlam

Destek ekibi, hesap kilitlenme şikayetlerini ele alırken her hafta
mühendisliğe "X kullanıcısı en son ne zaman giriş yaptı" diye soruyor. Veri
zaten CRM veritabanında mevcut; admin kullanıcı listesinde göstermek bu
kesintileri ortadan kaldırır.

## Kapsam

- **İçinde:** admin kullanıcı listesinde sıralanabilir bir "Son giriş" kolonu;
  göreli format ("3 gün önce") ve üzerine gelince tam zaman damgası.
- **Dışında:** giriş *geçmişi* ekranı; giriş tarihine göre filtreleme;
  girişlerin nasıl kaydedildiğine dair herhangi bir değişiklik.

## Kabul kriterleri

1. Giriş yapmış bir kullanıcı varken, admin listesi render olduğunda, kolon
   göreli zamanı gösterir ve üzerine gelince tam zaman damgası çıkar.
2. Hiç giriş yapmamış bir kullanıcı varken, liste render olduğunda, kolon
   çevrilmiş "Hiç" metnini gösterir — boşluk ya da hata değil.
3. Kolon başlığına tıklanınca, sıralama uygulandığında, hiç giriş yapmamış
   kullanıcılar her iki yönde de en sonda kalır.
4. 1.000 kullanıcılı liste mevcut performans bütçesinin altında render olur
   (satır başına ek istek yok).

## Veri kaynakları

| Kaynak (db.şema.tablo.kolon) | Anlamı                                  | Doğrulanma tarihi |
| ---------------------------- | --------------------------------------- | ----------------- |
| crm.dbo.Users.LastLoginAt    | son başarılı girişin UTC zaman damgası  | 2026-08-25        |
| crm.dbo.Users.Id             | portal kullanıcı id'sine join anahtarı  | 2026-08-25        |

Notlar: `LastLoginAt` satırların ~%8'inde NULL (2019 öncesi oluşturulmuş ya da
hiç giriş yapmamış kullanıcılar) — kriter 2'deki "Hiç" durumu budur. Zaman
damgaları UTC; arayüz yerelleştirmeli.

## Arayüz / i18n notları

Yalnızca admin kullanıcı listesi ekranı. Yeni metinler ("Son giriş", "Hiç")
desteklenen tüm dillerde i18n'den geçer. Yükleniyor durumu: kolon mevcut tablo
iskeletine katılır, ayrı bir spinner yok.

## Nasıl test edilir

1. Admin olarak admin kullanıcı listesini aç.
2. Yakın zamanda aktif bir kullanıcı bul → kolon göreli zamanı gösterir;
   üzerine gelince tam yerel zaman damgası çıkar.
3. 2019 öncesi bir kullanıcı bul (destek ekibi örnek verebilir) → çevrilmiş
   "Hiç" görünür.
4. Kolona göre iki yönde de sırala → "Hiç" olan kullanıcılar her iki yönde de
   en sonda.
5. Network panelini kontrol et: satır başına ek istek yok.

## Bitmişlik Tanımı (DoD)

- [ ] Tüm kabul kriterleri kanıtlanabilir şekilde karşılandı
- [ ] Kalite kapıları yeşil; sıralama davranışı bir bileşen testiyle kapsandı
- [ ] PR'da tarayıcı kanıtı ("Hiç" durumu dahil ekran görüntüsü, temiz konsol)
- [ ] Yeni metinler tüm dil dosyalarında mevcut

## Açık sorular / varsayımlar

- "Giriş" SSO yenilemelerini de kapsıyor mu, yoksa yalnız etkileşimli
  girişleri mi? — sahibi: A. Analist, kimlik ekibine soruyor, son tarih
  2026-08-28. Cevap gelene kadar kolon mevcut `LastLoginAt` semantiğiyle çıkar.
