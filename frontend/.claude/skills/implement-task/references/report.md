# <ID> — uygulama raporu

> Sınır ~60 satır. Sığmıyorsa iş çok büyük demektir: böl (`write-spec` → plan), rapor değil.

## Özet
2-4 cümle: ne yapıldı, ne yapılmadı.

## Değişen dosyalar
- `yol/dosya` — bir satır: ne değişti, neden

## Nasıl doğrulandı
Her komut + çıktının ilgili kısmı (özet, uydurma değil). Koşulmayan komut varsa "koşulmadı: <neden>".
UI değişikliğinde: `verify-ui` çıktısı (araç, tıklama yolu, ekran görüntüsü adları) ya da "browser smoke pending".
```
$ komut
çıktı
```

## Kabul kriterleri
- [x] karşılandı — kanıt: `test adı` / komut
- [ ] karşılanmadı — neden

## Kararlar ve varsayımlar
Spec'in / isteğin açık bıraktığı yerlerde ne seçildi, neden. Alternatif varsa bir satır.

## Sorular / bloklar
Cevap gerektiren her şey. Bloklanan iş bırakıldı, tahmin edilmedi.

## Kapsam dışı bırakılanlar / öneriler
Fark edilen ama dokunulmayan şeyler (ölü kod, komşu hata, iyileştirme). Dokunulmadı; yalnız not.
