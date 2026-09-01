# AI Dönüşümü — Agent Proje Şablonları

> English version: [README_en.md](README_en.md)
>
> **Standardın kendisi ve gerekçeleri:** [`ai-coding-standardi.docx`](ai-coding-standardi.docx)
> — ne kullandığımız, hangi açık kaynak projeyi neden aldığımız, neyi neden
> almadığımız ve riskler orada. Bu README nasıl kurulacağını anlatır; belge
> neden öyle olduğunu.

AI destekli geliştirme için standart, kopyala-kullan yapılar. **Tek yapı, iki
runtime:** aynı dosyaları hem GitHub Copilot (VS Code agent mode) hem Claude
Code okuyor.

| Parça          | Konum                        | Kim okuyor                        |
| -------------- | ---------------------------- | --------------------------------- |
| Agent rehberi  | `AGENTS.md`                  | Copilot native · Claude `CLAUDE.md` üzerinden |
| Bilgi tabanı   | `docs/`                      | Rehberin bağlantı verdiği kısa referanslar |
| Skill'ler      | `.claude/skills/*/SKILL.md`  | **İkisi de native** ([VS Code dokümantasyonu](https://code.visualstudio.com/docs/agent-customization/agent-skills)) |
| Özel ajanlar   | `.claude/agents/` · `.github/agents/` | Aynı içerik, her runtime kendi formatında |
| Hook script'leri | `.claude/hooks/*.sh`       | Tek script; manifest'i `.claude/settings.json` (Claude) + `.github/hooks/` (Copilot) |
| MCP sunucuları | `.mcp.json` · `.vscode/mcp.json` | Aynı sunucular, her runtime kendi dosyasında |
| Feature hafızası | `.ai/STATE.md` · `.ai/plans/` | Oturum aşan işin durumu ve planı |

## Şablonlar

- `templates_en/python-service/` — Python servisleri ve API'ler
- `templates_en/frontend-web/` — UI / frontend projeleri (React, Next.js vb.)
- `templates_en/analyst-workspace/` — iş analistleri: DB araştırması + görev yazımı

## Kurulum

```bash
python3 templates_en/start.py                        # etkileşimli
python3 templates_en/start.py frontend-web ~/kod/app # var olan depo
python3 templates_en/start.py --new python-service . # sıfırdan proje
```

Script şablonu hedef depoya kopyalar (var olan dosyaya **dokunmaz**, `--force`
ile ezer), sonra ekrana **bootstrap prompt**'unu basar. O metni Copilot'a ya da
Claude Code'a yapıştırırsın. Deponun durumuna göre iki farklı prompt basılıyor;
hangisinin doğru olduğunu script tahmin edip yanlış bayrakta uyarıyor.

**Var olan depo** (`bootstrap-prompt.md`) — agent depoyu tarar: manifest,
lockfile, CI, testler, git geçmişi. `AGENTS.md` ve `docs/` içindeki her
`PLACEHOLDER`'ı okuduğu dosyalardan doldurur, doğrulayamadığını `TODO(confirm)`
olarak işaretler, yığına özel skill'leri gerçek yollarla yeniden yazar ve eksik
önkoşulları raporlar.

**Sıfırdan proje** (`--new` → `bootstrap-prompt-greenfield.md`) — okunacak kod
yok, o yüzden ok ters yönde çalışır: dokümanlar koddan önce gelir. Agent önce
`tech-stack.md`'deki her `TODO` satırını sana **soru** olarak sorar (öneri +
gerekçe ile, tek turda), sonra kapıları gerçek kılan asgari iskeleti kurar —
lockfile, lint/format/type config, bir dikey dilim, bir test — ve dokümanları
ancak *kurduğu şeyden* doldurur. Kararlar aynı oturumda ADR'ye yazılır.

> Demir kural burada sertleşiyor: yalnız **insanın verdiği karar** ve
> **çalıştırdığın komutun çıktısı** olgu olarak yazılabilir. Var olan depoda
> yanlış bir satır kodla çelişir ve yakalanır; sıfırdan projede sessizce spec
> olur.

Sonrasında: `TODO(confirm)` maddelerini ekiple gözden geçir, ADR 0001'i imzala,
bir dosyayı düzenleyip hook'ların gerçekten ateşlediğini gör.

## Skill'ler

| Skill               | Ne yapar                                                        |
| ------------------- | --------------------------------------------------------------- |
| `implement-task`    | Bir isteği uçtan uca: anla → kur → kanıtla → kapılar → self-review → PR |
| `plan-feature`      | Tek oturuma sığmayan iş: önce plan dosyası, sonra görev görev yürütme |
| `debug-issue`       | Düzeltmeden önce kök neden: üret, sınırlara kanıt koy, kaynağa kadar izle |
| `run-quality-gates` | Kapıları koştur, her biri için gerçek çıktıyla rapor ver         |
| `self-review`       | Diff'i soğuk okuyan reviewer + gereksiz karmaşıklık taraması     |
| `record-decision`   | ADR yaz + etkilenen dokümanı aynı PR'da güncelle                 |
| `commit-and-pr`     | Commit/PR formatı: İngilizce conventional başlık, Türkçe gövde   |
| `verify-ui`         | (frontend) Değişikliği gerçek tarayıcıda kanıtla                 |
| `impeccable`        | (frontend) Tasarım kalitesi; `DESIGN.md`'ye karşı denetim        |
| `new-component` · `new-endpoint` · `db-migration` | Yığına özgü tarifler                |

Analist tarafında: `db-research`, `create-task`, `refine-task`,
`update-db-catalog`.

## Tarayıcıda doğrulama

`verify-ui` runtime'a göre elindeki tarayıcıyı kullanır, sırayla:

1. **VS Code'un yerleşik tarayıcı araçları** — Copilot agent mode, VS Code
   1.127+ ile GA. Sayfayı açar, konsolu okur, ekran görüntüsü alır, tıklar.
   Harici MCP gerekmez.
2. **Claude in Chrome** — Claude Code + Chrome eklentisi; gerçek oturumla
   gerçek tarayıcı (giriş yapılmış ekranlar için en iyisi).
3. **Playwright MCP** — temiz ve script'lenebilir; akış e2e testine
   dönüşecekse tercih edilir.

Üçü de yoksa skill "doğrulayamadım" der ve component testlerine düşer —
"kanıtlandı" demez.

## docs/ taksonomisi

- `docs/engineering/` — **nasıl** inşa ediyoruz: mimari, yığın, konvansiyonlar,
  test, iş akışı.
- `docs/domain/` — **ne** inşa ediyoruz: sözlük, iş kuralları. Kararlı referans.
- `docs/decisions/` — **neden**: numaralı, değişmez ADR'lar. Kararla aynı PR'da.

## Token ve maliyet

1. **Önce kısa doküman.** `AGENTS.md` her istekte ödenir — ≤ ~130 satır, her
   skill ≤ ~60 satır; detay linkli dokümana gider.
2. **Skill'ler gerektiğinde yüklenir.** İsabetli "ne zaman kullan" cümlesi
   eldeki en ucuz optimizasyondur.
3. **Yerleşik kod indeksi.** GitHub'da barındırılan depolar otomatik uzak
   semantik indeks alır. Lokal indeksleme ~2.500 dosyaya kadar iyi çalışır.
4. **Büyük depolar için MCP kod indeksi.** Gerekirse
   [claude-context](https://github.com/zilliztech/claude-context) veya
   [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp);
   benimsemeyi ADR olarak kaydet.
5. **Model karması.** Taslağı ucuz modelle yaz, `self-review` geçişini en güçlü
   modelle yap.

## Ne kullanıyoruz, ne kullanmıyoruz

Altı açık kaynak agent projesi incelendi. Sonuç "hepsini kur" değil: **yalnız
biri kuruldu**, diğerlerinden kod değil fikir alındı.

| Proje | Karar | Neden |
| --- | --- | --- |
| **Impeccable** | kuruldu | Tasarım kalitesi boşluğunu dolduran tek aday; 59 deterministik kural LLM'siz koşuyor, yani hook ve CI'a bağlanabiliyor. `.claude/skills/impeccable/`, ADR 0002 |
| **Ponytail** | fikri alındı | Eklentisi `copilot-instructions.md`'ye kural yazıyor; o dosya bizde bilinçli olarak yalnız işaretçi. Merdiven altın kural #4'e, kök-neden kural #5'e yazıldı |
| **Superpowers** | yazım deseni alındı, **eklenti kurulmadı** | Değeri skill'lerinde değil skill yazma biçiminde: iron law + red flags + ajanın bahanelerini önceden çürüten tablo — `run-quality-gates`, `debug-issue`, `self-review` bu kalıpla yazıldı. Eklentinin kendisi GSD ile aynı slotu doldurur, TDD'yi kültür olarak şart koşar (testten önce yazılmış kodu sildirir) ve her isteğe skill çağrısı bindirir |
| **GSD Core** | mekanizması alındı, framework kurulmadı | 70+ skill, kendi installer'ı ve kendi `.planning/` ağacı geliyor; kurulunca `AGENTS.md` ile ikinci bir doğruluk kaynağı oluşuyor. Değerli üç mekanizması `plan-feature` skill'ine sığdı |
| **Hallmark** | alınmadı | Impeccable ile aynı slot; çeşitlilik üretmek için tasarlanmış, üründe tutarlılık gerekiyor |
| **Caveman** | alınmadı | Kısa doküman politikasıyla çakışıyor, ajanik döngüde ölçülebilir tasarruf sağlamıyor |
| **Graphify** | sırada | Kod indeksi ihtiyacı doğmadı; yerleşik indeks ~2.500 dosyaya kadar yetiyor |

**Kaldırdıklarımız:** şablon senkronizasyonu (sürüm damgası + `standard-check`
CI kapısı — yarım mekanizmanın bakımı koruduğu değerden fazlaydı; repo sayısı
artınca kapı olarak değil PR açan bot olarak geri gelmeli) · `bootstrap-research`
skill'i (bir kerelik iş, kurulum prompt'una taşındı) · `simplify` skill'i
(sadeleştirme yazım anına, kural #4'e taşındı) · analist `task.md` şartı (iş
nereden gelirse gelsin, "done" gözlemlenebilirse alınır) · TR/EN şablon ikizliği.

Hepsinin uzun gerekçesi ve riskler:
[`ai-coding-standardi.docx`](ai-coding-standardi.docx).
