# AI Dönüşümü — Copilot Proje Şablonları

> English version: [README_en.md](README_en.md)

GitHub Copilot ile AI destekli geliştirme için standart, kopyala-kullan
yapılar. Bir ajanın ihtiyaç duyduğu her şey, Copilot'un **native** okuduğu üç
yerde yaşar:

| Parça         | Konum                       | Nedir                                                        |
| ------------- | --------------------------- | ------------------------------------------------------------ |
| Agent rehberi | `AGENTS.md` (depo kökü)     | Altın kurallar, komutlar, bilgi tabanı bağlantıları          |
| Bilgi tabanı  | `docs/`                     | Rehberin bağlantı verdiği kısa referans dokümanları          |
| Skill'ler     | `.github/skills/*/SKILL.md` | İş tarifleri; gerektiğinde yüklenir (progressive disclosure) |
| Özel ajanlar  | `.github/agents/*.agent.md` | Uzmanlaşmış personalar (ör. code-reviewer)                   |

## Şablonlar

Üç şablon, tek dil: **`templates_en/`**. Paralel bir Türkçe sürüm vardı ve
kaldırıldı — aynı şablonların ikiz kopyası, senkron tutulacak dosya sayısını
ikiye katlayıp netlik değil drift üretiyordu.

- `templates_en/frontend-web/` — UI / frontend projeleri (Next.js, React ve benzeri)
- `templates_en/python-service/` — Python servisleri ve API'ler
- `templates_en/analyst-workspace/` — iş analistleri: DB araştırması + görev yazımı

## Bir şablon nasıl benimsenir

1. `templates_en/<şablon>/` içeriğini hedef deponun köküne kopyalayın.
2. Depoyu Copilot ile açıp **`bootstrap-research`** skill'ini çalıştırın:
   gerçek kod tabanını (manifest'ler, CI, klasör yerleşimi) inceler ve `docs/`
   içindeki her `PLACEHOLDER` alanını kanıtla doldurur; emin olamadığını
   `TODO(confirm)` olarak işaretler.
3. `TODO(confirm)` maddelerini ekiple gözden geçirin, sonra işaretleri silin.
4. O andan itibaren doküman ve kodu `record-decision` skill'iyle (ADR'lar)
   senkron tutun.

## docs/ taksonomisi (neden üç klasör)

- `docs/engineering/` — **nasıl** inşa ediyoruz: mimari, yığın, konvansiyonlar,
  test, iş akışı.
- `docs/domain/` — **ne** inşa ediyoruz: sözlük, iş kuralları. Kararlı
  referans; yalnız bir kavram gerçekten değiştiğinde güncellenir, feature
  başına asla.
- `docs/decisions/` — **neden**: numaralı, değişmez ADR'lar. Değişen karar,
  eskisini geçersiz kılan yeni bir ADR alır. ADR kodla aynı PR'da gider.

## Token ve maliyet optimizasyonu

1. **Önce kısa doküman.** `AGENTS.md` + otomatik yüklenen her şeyin bedeli
   her istekte ödenir. Rehberi ≤ ~130 satır, her skill'i ≤ ~60 satır tutun;
   detay, yalnız gerektiğinde okunan bağlantılı dokümanlara gider.
2. **Skill'ler progressive disclosure'dır.** Copilot bir SKILL.md gövdesini
   yalnız description prompt'la eşleşince yükler. İsabetli "ne zaman kullan"
   cümlesi, eldeki en ucuz optimizasyondur.
3. **Copilot'un yerleşik kod indeksi.** GitHub'da barındırılan depolar
   otomatik olarak uzak semantik indeks alır (push'tan saniyeler sonra
   güncellenir) — kurulum yok, maliyet yok. Lokal indeksleme ~2.500 dosyaya
   kadar; ötesinde kalite düşer.
4. **Büyük depolar için MCP kod indeksi.** Bir depo yerleşik indeksi aşarsa ya
   da ajanlar grep'e token yakıyorsa bir indeks MCP sunucusu ekleyin:
   [zilliztech/claude-context](https://github.com/zilliztech/claude-context)
   (vektör arama, ~%40 token azaltımı) veya
   [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp)
   (tree-sitter AST bilgi grafı, yapısal sorgular). `.vscode/mcp.json` içinde
   tanımlayın; benimsemeyi ADR olarak kaydedin.
5. **Model karması.** Taslağı düşük maliyetli modelle yazın, incelemeyi en
   güçlü modelle yapın. Copilot'ta: scaffold/agent koşularında ucuz model,
   `self-review` geçişinde en güçlü model. "Codex yazar, Claude review eder"
   deseninin aynısı.

## Çalışma prensipleri

1. **Definition of Ready olmadan görev yok.** İş, geliştirici deposuna
   ölçülebilir kabul kriterleri, DoD, nasıl-test-edilir ve doğrulanmış veri
   kaynakları taşıyan bir `task.md` olarak girer. Analistin `refine-task`
   kapısı bunu zorlar; eksik görev tahminle değil, iadeyle karşılanır.
2. **Varsayım değil kanıt.** Analistler alan adlarını canlı şemaya karşı
   doğrular (salt okunur); geliştiriciler değişikliği tarayıcıda veya testle
   kanıtlar. Doğrulanmamış iddia `TODO(confirm)` etiketi alır, asla gerçek
   gibi yazılmaz.
3. **Her görev test getirir.** Uygun katman, şablonun test taksonomisinden
   gelir (unit / integration / e2e / smoke + teknolojiye özel katmanlar);
   PR, kabul kriterlerini testlerle eşler.
4. **Guardrail zinciri: hook → kapı → CI → review.** Copilot hook'ları
   otomatik formatlar ve hatırlatır (analist tarafında yazma-SQL'i reddeder);
   lokal kalite kapıları ve CI zorlar; reviewer söz değil kanıt okur.
5. **Küçük görevler, tek muhatap.** Görev başına tek çıktı; görev yazarı
   ulaşılabilir kalır ve cevaplarını görev dosyasını güncelleyerek verir.
6. **Kararlar netleştiği anda ADR olur** — kodla ve etkilenen dokümanla aynı
   PR'da.
7. **Token bilinçli harcanır.** Kısa dokümanlar, gerektiğinde yüklenen
   skill'ler, yerleşik kod indeksi ve model karması (ucuz model yazar, en
   güçlü model inceler).

## Yardımcı dokümanlar (Türkçe)

- `sunum.pptx` — bu yapıların ekibe sunumu (10 slayt, görselli)
- `rehber.docx` — ekip ve yöneticiler için kısa rehber, kaynakçalı
- `yapi-rehberi.docx` — yapıdaki her dosya ne için; hook'lar ve docs/
  klasörünün mantığı
- `mcp-rehberi.docx` — MCP nedir, analistler onunla nasıl çalışır, gerçekten
  şart mı
- `yol-haritasi.xlsx` — benimseme yol haritası, metrikler, riskler
