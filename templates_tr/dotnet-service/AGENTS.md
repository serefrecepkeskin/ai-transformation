# PROJE_ADI — Agent Rehberi

> **ŞABLON.** Bu klasörü depo köküne kopyala, ardından `bootstrap-research`
> skill'ini çalıştırarak tüm PLACEHOLDER alanlarını gerçek kod tabanından
> doldur.

PLACEHOLDER: tek paragraf — bu servis ne yapar, kimler tüketir, yığın
(.NET sürümü, ASP.NET Core / worker) ve nasıl dağıtılıyor.

Bu dosya, bu depoda çalışan her yapay zeka ajanı için kanonik rehberdir.
Detaylar `docs/` altında yaşar ve aşağıda bağlantılanır; bağlantılı dokümanı
doğru kaynak kabul et. Bu dosyayı ve tüm dokümanları **kısa** tut — bağlama
giren her şey her istekte token maliyeti üretir.

## Altın Kurallar

1. **Kodlamadan önce düşün.** Sessiz varsayım yok. Görev ya da bir iş kuralı
   belirsizse dur ve sor; her varsayımı açıkça yaz.
2. **Çalıştığını kanıtla.** "Yazıldı" yeterli değildir: davranış
   değişiklikleri testlerle, endpoint değişiklikleri endpoint'i lokalde
   gerçekten çağırarak doğrulanır. Bkz.
   [testing.md](docs/engineering/testing.md).
3. **Kapılar yeşil olmadan iş bitmez.** Her commit/PR öncesi
   `run-quality-gates` skill'ini çalıştır (build, format, test).
4. **Önce basitlik, cerrahi değişiklik.** Tam olarak istenen şeyi, mümkün olan
   en küçük diff ile yap. Alakasız refactor yok.
5. **Doğrulanabilir hedeflerle çalış.** Kabul kriterleri ve "nasıl test edilir"
   bölümü olmayan bir görev hazır değildir — iste.
6. **Konvansiyonlara uy.** Bkz.
   [conventions.md](docs/engineering/conventions.md); mevcut kodun stiline uy.
7. **Kararları proaktif kaydet.** Bir kütüphane/desen ya da domain kuralı
   yorumu netleştiği anda `record-decision` skill'ini çalıştır: ADR +
   etkilenen doküman güncellemesi, aynı PR'da. Emin değilsen kaydetmekten yana kullan.
8. **Sınırlarda doğrula.** Dış girdi (HTTP, kuyruk, üçüncü parti API)
   güvenilmezdir: kenarda doğrula, içeride tipli modeller dolaşsın. Nullable
   referans tiplerine saygı göster — uyarıyı susturmak için `!` kullanma.
9. **Push/PR öncesi öz-inceleme.** `self-review` skill'ini çalıştır
   (`code-reviewer` ajanı diff'i denetler); önce kritik/orta bulguları düzelt.
10. **İnsanlara düşen işleri takip et.** Secret'lar, erişimler, dış
    artifact'lar [manual-actions.md](docs/engineering/manual-actions.md)
    dosyasına yazılır.
11. **Şema değişikliği yalnız EF migration ile** — veritabanını ya da üretilmiş
    bir migration'ı elle düzenleme; `ef-migration` skill'ini kullan.

## Komutlar

PLACEHOLDER — bootstrap-research burayı solution/csproj/CI'dan doldurur.

- `dotnet run --project TODO` — lokalde çalıştır
- `dotnet build` · `dotnet format --verify-no-changes` · `dotnet test`

## Bilgi Tabanı

### Engineering (nasıl inşa ediyoruz)

- [architecture.md](docs/engineering/architecture.md)
- [tech-stack.md](docs/engineering/tech-stack.md)
- [conventions.md](docs/engineering/conventions.md)
- [testing.md](docs/engineering/testing.md)
- [development-workflow.md](docs/engineering/development-workflow.md)
- [manual-actions.md](docs/engineering/manual-actions.md)

### Domain (ne inşa ediyoruz)

Kararlı referans — bunları oku; yalnızca bir kavram gerçekten değiştiğinde
güncelle.

- [glossary.md](docs/domain/glossary.md)
- [business-rules.md](docs/domain/business-rules.md)

### Kararlar

Numaralı, değişmez ADR'lar: `docs/decisions/` (README + indeks).

## Yetkinlikler (skill'ler & ajanlar)

- **skill `implement-task`** — bir `task.md` dosyasını uçtan uca uygular.
  Zorunlu alanlar eksikse durur ve sorar.
- **skill `bootstrap-research`** — bu kod tabanını inceleyip `docs/` içindeki
  PLACEHOLDER alanlarını kanıtla doldurur.
- **skill `run-quality-gates`** — build + format + test, sonuçları raporlar.
- **skill `simplify`** — iş çalıştıktan sonra, self-review öncesi diff üzerinde
  kalite geçişi (yeniden kullanım, ölü ağırlık).
- **skill `new-endpoint`** — konvansiyonlara uygun API endpoint'i ekler.
- **skill `ef-migration`** — EF Core şema migration'ını güvenle oluşturur/uygular.
- **skill `record-decision`** — ADR yazar + etkilenen dokümanı günceller (kural #7).
- **skill `self-review`** — push/PR öncesi `code-reviewer` ajanı diff'i denetler.
- **skill `commit-and-pr`** — commit/PR formatı: İngilizce conventional-commit
  başlık, kanıtı taşıyan Türkçe gövde/açıklama.
- **ajan `code-reviewer`** — önem sırasına göre diff denetimi
  (doğruluk → nullability/async → sınırlar → test).

Guardrail'ler: bir Copilot hook'u oturum sonunda formatı doğrular ve doküman
drift'inde hatırlatır (`.github/hooks/`); güvenli komutlar `.vscode/settings.json`
içinde ön onaylıdır. Detay: [conventions.md](docs/engineering/conventions.md).

## Görev girişi

İşler, bir analist tarafından yazılan `task.md` olarak gelir (analist
workspace'indeki `task-template.md`): bağlam, kapsam, ölçülebilir kabul
kriterleri, DoD, nasıl test edilir ve veri kaynakları (hangi DB/tablo/kolon).
Bunlardan biri eksikse, tahmin etmek yerine görevin yazarından iste.
