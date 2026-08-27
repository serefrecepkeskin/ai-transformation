# PROJE_ADI — Agent Rehberi

> **ŞABLON.** Bu klasörü depo köküne kopyala, ardından `bootstrap-research`
> skill'ini çalıştırarak tüm PLACEHOLDER alanlarını gerçek kod tabanından
> doldur.

PLACEHOLDER: tek paragraf — bu uygulama nedir, kimler kullanır, render
stratejisi (SSR/CSR), hangi pazarlar/diller.

Bu dosya, bu depoda çalışan her yapay zeka ajanı için kanonik rehberdir.
Detaylar `docs/` altında yaşar ve aşağıda bağlantılanır; bağlantılı dokümanı
doğru kaynak kabul et. Bu dosyayı ve tüm dokümanları **kısa** tut — bağlama
giren her şey her istekte token maliyeti üretir.

## Altın Kurallar

1. **Kodlamadan önce düşün.** Sessiz varsayım yok. Görev, tasarım niyeti ya da
   bir iş kuralı belirsizse dur ve sor; her varsayımı açıkça yaz.
2. **Çalıştığını kanıtla.** "Yazıldı" yeterli değildir. Arayüz değişiklikleri
   `verify-ui` skill'i ile tarayıcıda doğrulanır (ekran görüntüsü, konsol,
   erişilebilirlik); mantık değişiklikleri testlerle doğrulanır. Bkz.
   [testing.md](docs/engineering/testing.md).
3. **Kapılar yeşil olmadan iş bitmez.** Her commit/PR öncesi
   `run-quality-gates` skill'ini çalıştır (typecheck, lint, format, test).
4. **Önce basitlik, cerrahi değişiklik.** Tam olarak istenen şeyi, mümkün olan
   en küçük diff ile yap. Alakasız refactor yok, ekstra özellik yok.
5. **Doğrulanabilir hedeflerle çalış.** Kabul kriterleri ve "nasıl test edilir"
   bölümü olmayan bir görev hazır değildir — iste.
6. **Konvansiyonlara uy.** Bkz.
   [conventions.md](docs/engineering/conventions.md); mevcut kodun stiline uy.
7. **Kararları proaktif kaydet.** Bir framework/kütüphane/desen ya da domain
   kuralı yorumu netleştiği anda `record-decision` skill'ini çalıştır:
   `docs/decisions/` altına ADR + etkilenen doküman güncellemesi, aynı PR'da.
   ADR'lık mı emin değilsen, kaydetmekten yana kullan.
8. **Kullanıcıya görünen metin i18n'den geçer**, asla hardcoded yazılmaz.
9. **Push/PR öncesi öz-inceleme.** `self-review` skill'ini çalıştır
   (`code-reviewer` ajanı diff'i denetler); önce kritik/orta bulguları düzelt.
10. **İnsanlara düşen işleri takip et.** Yalnızca bir insanın yapabileceği her
    şey (secret, erişim, dış artifact)
    [manual-actions.md](docs/engineering/manual-actions.md) dosyasına yazılır.
11. **Dokümanları kısa ve güncel tut.** Değişiklikten etkilenen dokümanı aynı
    anda güncelle; bağlantı yeterliyken uzun içerik yapıştırma.

## Komutlar

PLACEHOLDER — bootstrap-research burayı package.json script'lerinden doldurur.

- `npm run dev` — geliştirme sunucusu (TODO(confirm) port)
- `npm run typecheck` · `npm run lint` · `npm run format:check` · `npm run test`
- `npm run build`

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

- **skill `implement-task`** — bir `task.md` dosyasını uçtan uca uygular
  (oku → geliştir → doğrula → öz-incele → PR). Zorunlu alanlar eksikse durur ve sorar.
- **skill `bootstrap-research`** — bu kod tabanını inceleyip `docs/` içindeki
  PLACEHOLDER alanlarını kanıtla doldurur.
- **skill `verify-ui`** — bir arayüz değişikliğinin çalıştığını tarayıcıda
  kanıtlar (Playwright MCP).
- **skill `new-component`** — konvansiyonlara uygun yeni bileşen oluşturur.
- **skill `run-quality-gates`** — typecheck + lint + format + test, sonuçları raporlar.
- **skill `simplify`** — iş çalıştıktan sonra, self-review öncesi diff üzerinde
  kalite geçişi (yeniden kullanım, ölü ağırlık).
- **skill `record-decision`** — ADR yazar + etkilenen dokümanı günceller (kural #7).
- **skill `self-review`** — push/PR öncesi `code-reviewer` ajanı diff'i denetler.
- **skill `commit-and-pr`** — commit/PR formatı: İngilizce conventional-commit
  başlık, kanıtı taşıyan Türkçe gövde/açıklama.
- **ajan `code-reviewer`** — önem sırasına göre diff denetimi
  (doğruluk → erişilebilirlik → i18n → konvansiyonlar → test).

Guardrail'ler: Copilot hook'ları değişen dosyaları otomatik formatlar ve doküman
drift'inde hatırlatır (`.github/hooks/`); güvenli komutlar `.vscode/settings.json`
içinde ön onaylıdır. Detay: [conventions.md](docs/engineering/conventions.md).

## Görev girişi

İşler, bir analist tarafından yazılan `task.md` olarak gelir (analist
workspace'indeki `task-template.md`): bağlam, kapsam, ölçülebilir kabul
kriterleri, DoD, nasıl test edilir ve veri kaynakları. Bunlardan biri eksikse,
tahmin etmek yerine görevin yazarından iste.
