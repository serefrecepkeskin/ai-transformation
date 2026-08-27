# Analist Çalışma Alanı — Agent Rehberi

Bu depo, iş analistlerinin veri araştırıp geliştirme görevleri yazdığı yerdir.
Bu deponun çıktısı, bir geliştirici deposundaki `implement-task` skill'inin
tükettiği **`task.md`** dosyasıdır (bkz.
[task-template.md](docs/task-template.md)). Burada uygulama kodu yaşamaz.

## Altın Kurallar

1. **Her zaman salt okunur.** Bu çalışma alanından veritabanı erişimi yalnızca
   SELECT'tir. Hiçbir ortamda INSERT/UPDATE/DELETE/DDL çalıştırma. Bir görev
   verinin değişmesini gerektiriyorsa, bu *görevin içine* yazılır ve
   geliştiriciler yapar.
2. **Artifact'larda hassas veri olmaz.** Kolon adları, tipleri ve satır
   *şekilleri* kanıttır; gerçek müşteri değerleri (ad, e-posta, kimlik,
   bakiye) değildir. Hiçbir göreve, kataloğa veya sohbete PII ya da secret
   yapıştırma.
3. **Hafıza değil kanıt.** Bir görevde geçen her tablo/kolon, `db-research`
   skill'i ile canlı şemaya karşı doğrulanır ve doğrulama tarihi yazılır.
   Hafızadan alan adı yok.
4. **Sessiz varsayım yok.** Doğrulanmamış bir iş kuralı, görevin "Açık
   sorular" bölümüne açıkça işaretlenerek girer — asla gerçek gibi yazılmaz.
5. **Görev ya hazır çıkar ya hiç.** Teslimden önce `refine-task` geçmelidir:
   ölçülebilir kabul kriterleri, DoD, nasıl test edilir, veri kaynakları.
   Belirsiz bir görev bir agent döngüsünü boşa harcar; geri gelmesi, işi
   burada bitirmekten pahalıdır.
6. **Küçük görevler.** Görev başına tek çıktı. Kabul kriterleri tek ekrana
   sığmıyorsa böl.
7. **Kataloğu güncel tut.** Araştırma sırasında öğrenilen yeni şema bilgisi
   [db-catalog.md](docs/db-catalog.md) dosyasına işlenir (`update-db-catalog`).
8. **Yazar ulaşılabilir kalır.** Görev yazarını listeler; geliştirici soruları
   kaybolan sohbetlerde değil, görev dosyası güncellenerek yanıtlanır.

## Veritabanı bağlantıları (MCP)

Bağlantılar `.vscode/mcp.json` içinde tanımlıdır — motor başına bir salt okunur
MCP sunucusu (SQL Server, PostgreSQL, Oracle, MySQL). Kimlik bilgileri VS Code
input'ları ile sorulur ya da env değişkenlerinden okunur; **asla commit edilmez.**

> `mcp.json` içindeki sunucu komutları başlangıç örnekleridir. İlk kullanımdan
> önce, şirketçe onaylı MCP sunucusunu ve motor başına salt okunur bir DB
> kullanıcısını platform ekibiyle netleştir; prodüksiyon birincil sunucuları
> yerine replika/raporlama örneklerini tercih et.

Ek olarak bir Copilot hook'u (`.github/hooks/guard-readonly.json`, preToolUse)
yazma/DDL SQL içeren her tool çağrısını **reddeder** — salt okunur kullanıcının
üstüne derinlemesine savunma; onun yerine geçmez.

## Bilgi Tabanı

- [task-template.md](docs/task-template.md) — zorunlu görev formatı
- [how-analysts-work.md](docs/how-analysts-work.md) — çalışma yöntemi
- [db-catalog.md](docs/db-catalog.md) — hangi veritabanında ne var
- [definition-of-done.md](docs/definition-of-done.md) — şirket DoD temeli
- `tasks/` — yazılmış görevler, her biri tek dosya: `<ID>-<kebab-baslik>.md`

## Yetkinlikler (skill'ler)

- **skill `create-task`** — şablondan bir task.md yazar; veri referanslarını
  db-research ile doğrular; zorunlu alanlar bilinmiyorsa durur ve sorar.
- **skill `refine-task`** — mevcut bir görevin hazır olma denetimi; sıralı
  bulgular döndürür (eksik alan, ölçülemez kriter, doğrulanmamış varsayım).
- **skill `db-research`** — MCP bağlantılarıyla salt okunur şema/veri keşfi;
  alıntılanabilir kanıt üretir (şema.tablo.kolon, doğrulama tarihi).
- **skill `update-db-catalog`** — doğrulanmış bulguları db-catalog.md'ye işler.
- **skill `commit-and-pr`** — commit/PR formatı: İngilizce conventional-commit
  başlık, Türkçe gövde/açıklama.
