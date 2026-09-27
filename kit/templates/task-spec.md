# <ID> — <kısa başlık>

- **Repo(lar):** `<repo>` (yalnız bunlarda çalış; birden çoksa aralarındaki sözleşme Bağlam'da, repo repo uygula)
- **Dal / commit:** çalışma ağacında bırak, **commit etme** (aksi yazılmadıkça)
- **Kaynak belgeler:** `<docs/... §x>`, `<tasarım dokümanı>` — önce oku
- **Rapor:** repo başına `agent-work/<ID>/<repo>/report.md` (kit'in `templates/report.md` biçiminde; dili bu spec'in dili)

## Amaç
Tek cümle. "Bitti" gözlemlenebilir olmalı: hangi komut/ekran neyi gösterince bitmiş sayılır.

## Bağlam
Ajanın bilmesi gereken, koddan çıkarılamayacak şeyler: neden yapıyoruz, hangi karar verildi, nelere dokunulmayacak,
ilgili dosyalar (yol + ne işe yaradığı), önceki denemeler.

## Kabul kriterleri
- [ ] ölçülebilir madde (test adı / uç / ekran davranışı)
- [ ] ...

## Kısıtlar
- Repo `AGENTS.md` kuralları geçerli; çelişirse `AGENTS.md` kazanır ve rapora yaz.
- Zorunlu: `<örn. kapsam koşulu sorguda, migration yalnız şemanın sahibi repoda, secret okuma yok>`
- Yasak: `<örn. yeni HTTP istemcisi yazma, response modeli uydurma>`

## Kapsam dışı
Bilerek yapılmayacaklar (ajan "yapayım mı" diye düşünmesin diye).

## Doğrulama
```bash
# tam komutlar — rapora çıktı özetiyle girer
```

## Açık noktalar
Spec yazarının emin olmadığı yerler. Ajan bunları rapora "karar/varsayım" olarak yazar; sessizce seçmez.
