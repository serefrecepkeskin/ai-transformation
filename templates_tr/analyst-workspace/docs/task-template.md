# Görev Şablonu

Geliştirici deposuna teslim edilen her görev bu formata uyar. Geliştirici
tarafındaki `implement-task` skill'i, zorunlu bölümlerden biri eksik olan bir
görevi **reddeder**. Dosya adı: `tasks/<ID>-<kebab-baslik>.md`
(ör. `TASK-101-kullanici-disa-aktarim.md`).

```markdown
# <ID> — <Kısa, emir kipinde başlık>

- **Yazar:** <ad> (sorular için ulaşılabilir kalır)
- **Tarih:** YYYY-AA-GG
- **Hedef depo:** <depo adı> (<frontend | python | dotnet>)
- **Öncelik:** <yüksek | orta | düşük>

## Bağlam (zorunlu)

Bu neden gerekli, 3-6 cümle. Çözümü değil, kullanıcı/iş problemini anlat.
Varsa ilgili görev/ADR bağlantılarını ver.

## Kapsam (zorunlu)

- **İçinde:** bu görevin teslim ettiği şey.
- **Dışında:** açıkça teslim ETMEDİĞİ şey (kapsam kaymasını önler).

## Kabul kriterleri (zorunlu, ölçülebilir)

Her kriter bir testle veya gözlemle kontrol edilebilir olmalı — "düzgün
çalışmalı" olmaz. Mümkünse given/when/then kullan.

1. Şu durumdayken …, şunu yapınca …, şu olmalı …
2. …

## Veri kaynakları (veri söz konusuysa zorunlu)

db-research ile canlı şemaya karşı doğrulanmış — asla hafızadan değil.

| Kaynak (db.şema.tablo.kolon)  | Anlamı | Doğrulanma tarihi |
| ----------------------------- | ------ | ----------------- |
| crm.dbo.Customers.LastLoginAt | …      | YYYY-AA-GG        |

Notlar: önemli join/filtreler, araştırmada bulunan veri tuhaflıkları
(null olabilirlik, formatlar, tuzaklar). Yalnızca kolon adları ve şekiller —
gerçek müşteri değerleri yok.

## Arayüz / i18n notları (arayüz görevlerinde zorunlu)

Etkilenen ekran/bileşenler, durumlar (yükleniyor/boş/hata) ve kullanıcıya
görünen tüm metnin çevrilebilir olması gerektiği hatırlatması. Varsa tasarım
referansları.

## Nasıl test edilir (zorunlu)

Bir geliştiricinin (ya da ajanının) uygulayabileceği somut adımlar: nereye
tıklanacak / ne çağrılacak, hangi girdiyle ve ne gözlemlenmeli. Uç durumları
da ekle.

## Bitmişlik Tanımı — DoD (zorunlu)

definition-of-done.md'deki temel liste, artı göreve özel maddeler:

- [ ] Tüm kabul kriterleri kanıtlanabilir şekilde karşılandı
- [ ] Kalite kapıları yeşil; yeni davranış testlerle kapsandı
- [ ] <göreve özel madde>

## Açık sorular / varsayımlar

Doğrulanmamış her şey, sahibi belli olacak şekilde: kim, ne zamana kadar
cevaplayacak. Bölümün boş olması "hiçbir varsayım yok" demektir.
```
