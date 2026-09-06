# <ID> — <kısa başlık>

- **Repo:** `<repo>` (yalnız burada çalış; başka repoya dokunma)
- **Dal / commit:** çalışma ağacında bırak, **commit etme** (aksi yazılmadıkça)
- **Kaynak belgeler:** `<docs/... §x>`, `<ADR NNNN>` — önce oku
- **Rapor:** `agent-work/<ID>/report.md` (`implement-task` → `references/report.md` biçiminde; dili bu spec'in dili)

## Amaç
Tek cümle. "Bitti" gözlemlenebilir olmalı: hangi komut/ekran neyi gösterince bitmiş sayılır.

## Bağlam
Ajanın bilmesi gereken, koddan çıkarılamayacak şeyler: neden yapıyoruz, hangi karar verildi, nelere dokunulmayacak,
ilgili dosyalar (yol + ne işe yaradığı), taklit edilecek dosyalar, önceki denemeler.

## Kabul kriterleri
- [ ] ölçülebilir madde (test adı / uç / ekran davranışı)
- [ ] ...

## Kısıtlar
- Repo `AGENTS.md` kuralları geçerli; çelişirse `AGENTS.md` kazanır ve rapora yaz.
- Zorunlu: `<örn. tenant/user yüklemi sorguda, migration yalnız bu repoda, secret okuma yok>`
- Yasak: `<örn. yeni HTTP istemcisi yazma, response model uydurma>`

## Kapsam dışı
Bilerek yapılmayacaklar (ajan "yapayım mı" diye düşünmesin diye).

## Doğrulama
```bash
# tam komutlar — rapora çıktı özetiyle girer
```

## Açık noktalar
Spec yazarının emin olmadığı yerler. Ajan bunları rapora "karar/varsayım" olarak yazar; sessizce seçmez.
