# AI Dönüşümü — Agent Proje Şablonları

> English version: [README_en.md](README_en.md)

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
python3 templates_en/start.py frontend-web ~/kod/app # doğrudan
```

Script şablonu hedef depoya kopyalar (var olan dosyaya **dokunmaz**, `--force`
ile ezer), sonra ekrana **bootstrap prompt**'unu basar. O metni Copilot'a ya da
Claude Code'a yapıştırırsın: depoyu tarar, `AGENTS.md` ve `docs/` içindeki her
`PLACEHOLDER`'ı gerçek kanıtla doldurur, emin olamadığını `TODO(confirm)` olarak
işaretler, yığına özel skill'leri gerçek yollarla yeniden yazar ve eksik
önkoşulları raporlar. Prompt tek başına da kullanılabilir:
`templates_en/bootstrap-prompt.md`.

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

## Kapsam dışı bırakılanlar

- **Şablon senkronizasyonu.** Depolar arası drift'i ölçen sürüm damgası ve
  `standard-check` CI kapısı kaldırıldı; şu an öncelik değil. Repo sayısı
  artınca geri gelmesi gereken ilk şey budur.
- **Analist bağımlılığı.** Geliştirici şablonları artık analist yazımı bir
  `task.md` şart koşmuyor; iş nereden gelirse gelsin, "done" gözlemlenebilir
  olarak ifade edilebiliyorsa alınır. Analist şablonu bağımsız durmaya devam
  ediyor.

Değerlendirme ve gerekçeler: `ai-coding-standardi.docx`.
