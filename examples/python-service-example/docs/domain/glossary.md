# Domain Sözlüğü

> **Güncelleme politikası:** kararlı referans — bir terim ilk kez
> tanımlandığında veya gerçekten değiştiğinde güncellenir.

| Terim            | Tanım                                                                  |
| ---------------- | ---------------------------------------------------------------------- |
| Sipariş (Order)  | Bir müşterinin tek seferde verdiği, kalemlerden oluşan satın alma kaydı |
| Sipariş kalemi (OrderItem) | Siparişteki tek ürün satırı: ürün, adet, birim fiyat anlık görüntüsü |
| Müşteri (Customer) | Sipariş verebilen kayıtlı hesap                                       |
| Durum (Status)   | Siparişin yaşam döngüsü adımı: DRAFT, CONFIRMED, PAID, SHIPPED, DELIVERED, CANCELLED |
| Taslak (DRAFT)   | Sepetten oluşturulmuş, henüz onaylanmamış sipariş                       |
| Onay (CONFIRMED) | Stok düşümünün yapıldığı geçiş; fiyatlar bu anda sabitlenir             |
| Toplam tutar     | Kalemlerden türetilen değer; asla elle yazılmaz                          |
| İptal (CANCELLED)| Kargolanmamış siparişin sonlandırılması; stok iade edilir               |
| BFF              | Web/mobil arayüzlerin bu servisi tükettiği ara katman                    |
| PII              | Kişiyi tanımlayan veri (ad, e-posta, adres); loglanması yasak            |
