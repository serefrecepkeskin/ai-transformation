# İş Kuralları

> **Güncelleme politikası:** kararlı referans. Bir kural yorumu kodun içine
> gömüldüğünde bir ADR ile kaydedilir.

## Doğrulanmış kurallar

> Bağlayıcıdır. Bunlardan biriyle çelişen kod, tasarım tercihi değil hatadır.

- **Durum geçişleri tek yönlüdür:** DRAFT → CONFIRMED → PAID → SHIPPED →
  DELIVERED. Geriye dönüş yok; tek yan çıkış CANCELLED.
- **İptal yalnız kargodan önce:** SHIPPED ve sonrasındaki bir sipariş iptal
  edilemez; iade süreci ayrıdır.
- **Toplam tutar türetilir:** siparişin toplamı kalemlerden hesaplanır;
  API'den toplam kabul edilmez, elle yazılamaz.
- **Stok CONFIRMED anında düşer,** CANCELLED'da iade edilir; DRAFT stok tutmaz.
- **Fiyat anlık görüntüsü:** kalem birim fiyatı CONFIRMED anında sabitlenir;
  sonradan ürün fiyatı değişse de sipariş etkilenmez.

## Doğrulanmamış varsayımlar

> **Gerçek gibi ele alma.** Onaylananlar yukarı taşınır.

- TODO(confirm): **Kısmi iade** — DELIVERED sonrası kalem bazında iade mümkün
  mü, süresi ne? Sahibi: iş analisti; manual-actions'ta takipte.
- TODO(confirm): **DRAFT ömrü** — taslak siparişler ne kadar sonra otomatik
  silinmeli? Şu an sınırsız tutuluyor.
