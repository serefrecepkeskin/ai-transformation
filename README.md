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
| Kalite kapısı  | `.pre-commit-config.yaml` (pip) · `.husky/pre-commit` (npm) | git, commit anında — ajandan bağımsız |
| İzin / gizlilik | `.vscode/settings.json` · `.claude/settings.json` | Her runtime kendi dosyasında, aynı politika |

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

## Lint kapısı — projede yoksa nasıl geliyor

Üç an var, üçü farklı soruyu çözüyor. Karışan yer genelde 1 ile 3'ün farkı:
**script dosyayı koyar, ajan yığına uydurur.**

Her şablon **kendi ekosisteminin aracını** getiriyor; ikinci bir toolchain
kurulmuyor:

| Şablon | Commit-anı aracı | Gelen dosyalar | Neyle bağlanıyor |
| --- | --- | --- | --- |
| `python-service` | `pre-commit` (pip) | `.pre-commit-config.yaml`, `requirements-dev.txt` | `pre-commit install` |
| `frontend-web` | `husky` + `lint-staged` (npm) | `.husky/pre-commit`, `.lintstagedrc.json`, `eslint.config.js` | `npm install` — `prepare` script'i üzerinden |

> `husky`, git'in hook mekanizmasını paylaşılabilir yapan ~2KB'lık npm paketi:
> `.git/` klonlanmadığı için hook repoda duramaz; husky script'leri versiyonlanan
> `.husky/` klasöründe tutup git'in `core.hooksPath` ayarını oraya çeviriyor ve
> bunu `npm install`'un çalıştırdığı `prepare` script'iyle yapıyor — yeni gelen
> ekip üyesi fazladan hiçbir şey yapmıyor. `lint-staged` ise komutu yalnız staged
> dosyalara koşuyor. Python'ın `pre-commit`'inin resmî npm dağıtımı yok;
> frontend'e pip sokmamanın sebebi bu.

1. **`start.py` kopyalar.** Şablonun kendi kapı dosyaları depoya yazılır,
   **yalnız o dosya orada yoksa**. Varsa deponun kendi hâli kazanır ve çıktıdaki
   "left untouched" listesinde görünür. Yani "yoksa ekle" davranışı kopyalamanın
   kendisinde.
2. **`start.py` raporlar.** Kopyalamadan sonra bir `lint readiness` bloğu basar
   ve hangi aracın indiğine göre doğru soruları sorar: python'da `pre-commit`
   PATH'te mi ve `.git/hooks/pre-commit` bağlı mı; frontend'de `lint-staged`
   kurulu mu, `package.json`'da `prepare` script'i var mı, `core.hooksPath`
   `.husky/`'ye dönmüş mü. **Hiçbir şey kurmaz.** Yalnız pre-commit tarafında,
   etkileşimli modda tek bir soru sorar ve açık `y` ile çalıştırır — `.git/hooks/`
   altına izinsiz yazmak, ajandan istediğimiz davranışın tersi olurdu. husky
   tarafında böyle bir soru yok, çünkü `npm install` zaten bağlıyor.
3. **Bootstrap prompt'u uyarlar.** Asıl karar burada, çünkü yığını *okumak*
   gerekiyor. Prompt ajana üç durumu ayırtıyor:
   - **(a) depoda lint yoktu** → gelen config artık kurulumun kendisi:
     `[tool.ruff]`/`[tool.pylint]` bloğu **var olan** `pyproject.toml`'a eklenir
     (şablon bilerek `pyproject.toml` taşımıyor, ezmesin diye),
     `rev:` pin'leri kurulu sürümlerle eşitlenir. Frontend'de
     `npm i -D husky lint-staged` + `npm pkg set scripts.prepare=husky` +
     `npm install` ile hook gerçekten bağlanır ve `eslint.config.js`
     TypeScript/Next.js'e uyarlanır. Sonra tüm-ağaç taraması
     (`pre-commit run --all-files` ya da `npm run lint`) **bir kez** koşulur:
     eski kodun patlaması beklenen şey, o yüzden sayı olarak *raporlanır* —
     sessizce toplu format atılmaz, kural gevşetilmez. Uymayan bir kural config
     düzenlemesi değil, ADR konusudur.
   - **(b) depoda zaten lint vardı** → onlarınki kalır. Gelen kapı onların
     komutlarını çağıracak şekilde yeniden yazılır, kopya kontroller silinir.
     Kapının tek bir tanımı olur.
   - **(c) depoda zaten bir commit hook'u vardı** (kendi husky kurulumu,
     `package.json` içinde lint-staged, simple-git-hooks ya da elle yazılmış
     `.git/hooks/pre-commit`) → iki kapı bir kapıdan kötü. Şablonun kontrolleri
     onlarınkine katılır ve şablonunki silinir, ya da tersi; ajan hangisini
     seçtiğini söyler ve sonunda tek hook koşar.
4. **Sonrasında kapı ayakta kalır.** `AGENTS.md` → Commands'ta kapının komutu,
   `run-quality-gates` skill'inde tüm-ağaç karşılığı. `--no-verify` yok.

Her klonda bir kez: python'da `pip install pre-commit && pre-commit install`,
frontend'de sadece `npm install`. Bunu README'ye ve `manual-actions.md`'ye
yazmak bootstrap adımının işi.

## Gizlilik ve izinler

Üç katman var ve üçü farklı şeyi garanti ediyor — hangisinin ne yaptığını
bilmeden birine güvenmek asıl risk:

| Katman | Nerede | Ne yapar |
| --- | --- | --- |
| **Keşif** | `search.exclude`, `files.associations`, `github.copilot.enable`, `.gitignore` | Sır dosyalarını aramadan, workspace index'inden ve inline completion'dan çıkarır. Hedefli bir okumayı **durdurmaz** |
| **Eylem** | `chat.tools.terminal.autoApprove`, `chat.tools.edits.autoApprove`, `chat.agent.sandbox.enabled`, `permissions.deny` | Komutta ve düzenlemede onay kapısı. **Claude Code**'da `Read()`/`Edit()` deny gerçek blok — dosya araçlarını *ve* Claude Code'un tanıdığı `cat`/`head`/`tail`/`sed` komutlarını kapsıyor. Sandbox, iki tarafta da tek OS düzeyi blok |
| **Prompt** | Golden rule: "sırlar okunmaz, yazdırılmaz, yapıştırılmaz" | Diğer ikisinin kapatamadığını kapatır |

Deny listesi neden "bütün `.ini`'ler kapalı" değil: **deny kuralı istisna kabul
etmiyor.** `Read(**/*.ini)` yazarsan `alembic.ini`, `pytest.ini` ve `setup.cfg` de
kapanır, geri açmanın yolu yoktur — `db-migration` skill'i o gün çalışmaz. O yüzden
liste cerrahi: `.env*`, anahtar/sertifika, `secrets/**`, `~/.ssh`, `~/.aws`,
`default.ini`, `config/*.ini`.

**Dürüst sınır:** GitHub'ın content exclusion özelliği Copilot'ın **agent ve edit
modlarında uygulanmıyor** ve Business/Enterprise istiyor. Yani Copilot tarafında
dosya okumaya kesin bir blok yok; oradaki katman onay + keşif + prompt. Hiç
okunmaması gereken bir sır workspace'te değil, vault'ta durmalı.

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
| **Karpathy skills** ([multica-ai](https://github.com/multica-ai/andrej-karpathy-skills)) | fikri alındı | Dört prensipten üçü Golden Rules'da zaten daha ayrıntılı karşılanıyordu: *Simplicity First* → kural #4'ün merdiveni, *Goal-Driven Execution* → kural #2/#3 + `implement-task`'ın "kanıtı adlandıramıyorsan görev hazır değil" adımı. Gerçek boşluk iki maddeydi ve işlendi: alternatifleri sunma/itiraz kural #1'e, **cerrahi değişiklik testi** (değişen her satır isteğe kadar izlenebilmeli, komşu kodu düzeltme, orphan'ını temizle) kural #4'e. Skill/eklenti olarak kurulmadı — `AGENTS.md`'nin yanında ikinci bir doğruluk kaynağı olurdu (GSD Core ile aynı gerekçe) |
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
