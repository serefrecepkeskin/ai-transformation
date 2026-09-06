# AI Dönüşümü — Şirket Agent Kit'i

> English version: [README_en.md](README_en.md)
>
> **Standardın kendisi ve gerekçeleri:** [`ai-coding-standardi.docx`](ai-coding-standardi.docx)
> — ne kullandığımız, hangi açık kaynak projeyi neden aldığımız, neyi neden
> almadığımız ve riskler orada. Bu README nasıl kurulacağını ve nasıl
> çalışıldığını anlatır; belge neden öyle olduğunu.

AI destekli geliştirmenin ortak yapısı. **Tek kopya, iki harness:** aynı skill
ve ajan tanımlarını GitHub Copilot (VS Code agent mode / coding agent) ve
Claude Code okur. Codex yok. Kit her şirket reposuna **kopyalanarak, reponun
içine** kurulur; backend ve frontend ayrı repolardır ve her biri kendi profilini
alır. Üç klasör var — `backend/`, `frontend/`, `analyst/` — ve her biri o tip reponun
**içine kopyalanacak hâliyle** hazırdır: `AGENTS.md` iskeleti, `docs/` bilgi
tabanı, skill'ler, reviewer ajanları (Copilot ikizleri dahil), hook'lar, izin
dosyaları, commit kapısı. Repo başına kurallar her zaman o reponun
`AGENTS.md`'sindedir; kit rolleri, iş akışını ve guardrail'leri tanımlar.

## Roller

| Rol | Kim | Ne yapar |
|---|---|---|
| **Yürütücü** | Geliştiricinin Claude Code / Copilot oturumu | İşi parçalar, gerekirse `write-spec` ile `agent-work/<id>/spec.md` yazar, uygular ya da delege eder, sonucu **bağımsız doğrular** (diff'i okur, testleri kendisi koşar), review turunu (ajanlar) yürütür, raporlar. Commit/push kullanıcı söylemeden yapılmaz. |
| **Uygulayıcı** | Aynı oturum (`implement-task`) **ya da** geçmişsiz bir oturum: Claude alt-ajanı / worktree, Copilot coding agent (issue → PR), başka bir geliştirici | `spec.md`'yi uygular, `report.md` yazar. Bloklanırsa tahmin etmez, rapora soru yazar. |
| **Gözden geçirici** | `code-reviewer` (stack merceği) + `security-reviewer` ajanları — Claude subagent ya da Copilot custom agent | Diff'i **soğuk** okur (amaç var, yazarın anlatımı yok), önem sıralı bulgu listesi döner, dosya değiştirmez. |
| **UI doğrulayıcı** | `verify-ui` (her UI değişikliğinde) · `ui-check` (yayın öncesi) | Gerçek tarayıcıda kanıt üretir: ekrana UI üzerinden ulaşma, taşma/üst üste binme/kaydırma/modal kalıntısı probe'ları, konsol, erişilebilirlik, eklenen işlevin uçtan uca çalışması; `ui-check` ekran × rol × viewport matrisidir. |

## Harness haritası — kim neyi okur

| İçerik | Kanonik kaynak | Claude Code | Copilot |
|---|---|---|---|
| Repo rehberi | `AGENTS.md` | `CLAUDE.md` (`@AGENTS.md`) | doğrudan; `.github/copilot-instructions.md` yalnız işaretçi |
| Bilgi tabanı | `docs/` | rehberin bağlantı verdiği kısa referanslar | aynı |
| Skill'ler | `.claude/skills/*/SKILL.md` | native | native ([VS Code dokümantasyonu](https://code.visualstudio.com/docs/agent-customization/agent-skills)) |
| Reviewer ajanları | `.claude/agents/*.md` | native | `.github/agents/*.agent.md` — `sync-copilot-agents.py` **üretir**, klasörde hazır |
| Hook script'leri | `.claude/hooks/*.sh` | manifest `.claude/settings.json` | manifest `.github/hooks/*.json` |
| MCP sunucuları | `.mcp.json` | native | `.vscode/mcp.json` |
| İzin / gizlilik | politika | `.claude/settings.json` | `.vscode/settings.json` |
| İş izi | `agent-work/<id>/` (dalla commit, merge'de silinir; `shots/` ignore) | yazar/okur | yazar/okur |
| Commit kapısı | `.pre-commit-config.yaml` (pip) · `.husky/pre-commit` (npm) | git, commit anında — ajandan bağımsız | aynı |

## İş akışı (bir görev)

```
1. Yürütücü  → write-spec ile agent-work/<id>/spec.md   (amaç, kabul kriterleri, kısıtlar, doğrulama komutları)
              küçük işte spec atlanır: implement-task doğrudan
2. Uygulayıcı → implement-task: AGENTS.md okur, uygular, kapıları koşar, report.md yazar
3. Yürütücü  → raporu OKUMAKLA YETİNMEZ: diff'i inceler, testleri kendisi koşar ("yeşil" demek kanıt değildir)
4. Yürütücü  → code-reviewer (+ security-reviewer) ajanları diff'i soğuk okur → review.md; critical/medium düzeltme turu (2'ye döner)
5. Yürütücü  → UI dokunulduysa verify-ui (tarayıcı); yayın öncesi ui-check
6. Yürütücü  → commit-and-pr (yalnız kullanıcı isterse); PR açıklaması report.md'den türer
```

`agent-work/<id>/` bir görevin bütün izidir: `spec.md`, `plan.md`
(`write-spec`), `report.md`, `review.md`, `ui-smoke.md`, `ui-bugs.md`.
Dalla birlikte commit edilir (reviewer spec'i ve raporu orada okur), merge'den
önceki son commit'te silinir; yalnız `shots/` ignore'dadır. Kalıcı olması
gereken bilgi ADR'a ya da `docs/`'a taşınır.
Şablonları skill'lerin `references/` klasörlerindedir, kitle birlikte gelir.

## Kurulum

Kit ayrı bir repodur; profil klasörü hedef repoya **kopyalanır** (symlink yok,
submodule yok). Klasörün içindeki her dosya hedef repoda aynı göreli yola gider.

| Klasör | Ne için | Getirdiği ek |
|---|---|---|
| `backend/` | Python servisleri ve API'ler | pre-commit kapısı, `new-endpoint`, `db-migration` |
| `frontend/` | React / Next.js vb. | husky + lint-staged kapısı, `verify-ui`, `ui-check`, `new-component`, `impeccable`, `docs/DESIGN.md`, `docs/screens.md`, Playwright e2e iskeleti + MCP |
| `analyst/` | İş analistleri: salt-okunur DB araştırması + görev yazımı | DB MCP bağlantıları, salt-okunur SQL guard'ı; kod skill'i, format hook'u, reviewer ajanı **gelmez** |

```bash
git clone <kit-url> ~/kod/ai-transformation
~/kod/ai-transformation/install.sh backend  ~/kod/servis-repo                  # sorar: claude / copilot / both
~/kod/ai-transformation/install.sh frontend ~/kod/yeni-repo --new --tool copilot  # sıfırdan proje, sormadan
```

Script önce hangi AI aracının kullanıldığını sorar — `claude`, `copilot` ya da
`both` (`--tool` ile de verilir; terminal yoksa `both`) — ve yalnız o runtime'ın
dosyalarını kopyalar: `claude` Copilot tarafını (`.github/copilot-instructions.md`,
`.github/agents/`, `.github/hooks/`, `copilot-setup-steps.yml`, `.vscode/`) dışarıda
bırakır; `copilot` Claude tarafını (`CLAUDE.md`, `.claude/settings.json`,
`.mcp.json`) bırakır. `.claude/skills`, `.claude/hooks` ve `.claude/agents` her
zaman gelir: Copilot skill'leri native okur, manifest'leri aynı script'leri
çağırır, ikizler o ajanlardan üretilir. Sonra klasörü kopyalar (var olan
dosyaya **dokunmaz**, `--force` ile ezer, atladıklarını listeler), `.gitignore`'a
`agent-work/**/shots/` ekler ve ekrana **bootstrap prompt**'unu basar. O metni Copilot'a ya da Claude Code'a
yapıştırırsın. Script'siz de olur: `cp -R backend/. <repo>/` + `.gitignore`'a
`agent-work/**/shots/`. Git deposu olmayan bir dizinde uyarır, çünkü hook'lar yollarını
git üzerinden çözer. Windows'ta Git Bash ya da WSL.

**Var olan repo** (`bootstrap-prompt.md`) — ajan depoyu tarar: manifest,
lockfile, CI, testler, git geçmişi. `AGENTS.md` ve `docs/` içindeki her
`PLACEHOLDER`'ı okuduğu dosyalardan doldurur, doğrulayamadığını `TODO(confirm)`
olarak işaretler, yığına özel skill'leri gerçek yollarla yeniden yazar,
frontend'de `docs/screens.md` ekran envanterini router'dan çıkarır ve eksik
önkoşulları raporlar.

**Reponun zaten `AGENTS.md`'si varsa** kit'inki atlanır ve reponunki kalır.
Prompt bu durumu bilir: kuralları yeniden yazmaz, yalnız *Capabilities*,
*Guardrails* ve *Work trail* bölümlerini kit şablonundan ekler.

**Sıfırdan proje** (`--new` → `bootstrap-prompt-greenfield.md`) — okunacak kod
yok, ok ters yönde çalışır: dokümanlar koddan önce gelir. Ajan önce
`tech-stack.md`'deki her `TODO` satırını sana **soru** olarak sorar (öneri +
gerekçe ile, tek turda), sonra kapıları gerçek kılan asgari iskeleti kurar —
lockfile, lint/format/type config, bir dikey dilim, bir test — ve dokümanları
ancak *kurduğu şeyden* doldurur. Kararlar aynı oturumda ADR'ye yazılır.

> Demir kural: yalnız **insanın verdiği karar** ve **çalıştırılan komutun
> çıktısı** olgu olarak yazılabilir. Var olan repoda yanlış bir satır kodla
> çelişir ve yakalanır; sıfırdan projede sessizce spec olur.

Sonrasında: `TODO(confirm)` maddelerini ekiple gözden geçir, ADR 0001'i
imzala, bir dosyayı düzenleyip hook'ların gerçekten ateşlediğini gör.

### Kit güncellenince

Kopya kurulumun bedeli drift'tir. Kit'te bir skill, ajan ya da hook değişince:

```bash
./diff-repo.sh backend ~/kod/servis-repo          # drift <yol> / missing <yol> / clean; drift varsa exit 1; aracı kendisi anlar
./install.sh   backend ~/kod/servis-repo --force  # ya da tek dosyayı elle kopyala
```

`diff-repo.sh` kit'e ait dosyaları (hook'lar, ortak skill'ler, ajanlar ve
ikizleri) bayt bayt karşılaştırır; bootstrap'ten sonra repoya ait olan
dosyaları (`AGENTS.md`, `docs/`, PLACEHOLDER taşıyan stack skill'leri, ayar ve
kapı dosyaları) yalnız eksikse raporlar. Repo sayısı artınca bu komut CI'da
kapı değil, PR açan bot olarak koşmalı.

**Kit'in kendi içindeki kopyalar:** `backend/` ve `frontend/` aynı ortak
dosyaları taşır (`CLAUDE.md`, `copilot-instructions.md`, hook'lar,
`security-reviewer`, üç ortak skill); `analyst/` yalnız `CLAUDE.md`,
`copilot-instructions.md` ve `commit-and-pr`'ı paylaşır. Birinde değiştirince
diğerine kopyala; `diff -rq backend/.claude/skills frontend/.claude/skills`
farkı gösterir. Bir ajanı düzenleyince `python3 sync-copilot-agents.py backend`
(ya da `frontend`) ikizini yeniler; ikizler elle yazılmaz.

**Impeccable güncellemesi:** bir frontend repoda `npx impeccable update`
çalıştır, sonra `.claude/skills/impeccable/` ve
`.github/agents/impeccable-*.agent.md`'yi `frontend/` altına geri kopyala
(ADR 0002).

## Lint kapısı — projede yoksa nasıl geliyor

Her profil **kendi ekosisteminin aracını** getirir; ikinci bir toolchain
kurulmaz:

| Profil | Commit-anı aracı | Gelen dosyalar | Neyle bağlanıyor |
| --- | --- | --- | --- |
| `backend` | `pre-commit` (pip) | `.pre-commit-config.yaml`, `requirements-dev.txt` | `pre-commit install` |
| `frontend` | `husky` + `lint-staged` (npm) | `.husky/pre-commit`, `.lintstagedrc.json`, `eslint.config.js` | `npm install` — `prepare` script'i üzerinden |

> `husky`, git'in hook mekanizmasını paylaşılabilir yapan küçük npm paketi:
> `.git/` klonlanmadığı için hook repoda duramaz; husky script'leri
> versiyonlanan `.husky/` klasöründe tutup `core.hooksPath`'i oraya çevirir,
> bunu `npm install`'un çalıştırdığı `prepare` ile yapar. `lint-staged` komutu
> yalnız staged dosyalara koşar. Python'ın `pre-commit`'inin resmî npm dağıtımı
> yok; frontend'e pip sokmamanın sebebi bu.

Üç an var: **script dosyayı koyar** (yalnız yoksa; varsa reponunki kazanır ve
"left untouched" listesinde görünür), **bootstrap prompt yığına uydurur**
(depoda lint yoktu → gelen config kurulumun kendisidir, `[tool.ruff]` var olan
`pyproject.toml`'a eklenir, husky bağlanır, tüm-ağaç taraması **bir kez** koşup
sayı olarak raporlanır; depoda lint vardı → onlarınki kalır, kapı onların
komutlarını çağırır; depoda commit hook'u vardı → iki kapı bir kapıdan kötü,
biri seçilir), **sonrasında kapı ayakta kalır** (`AGENTS.md → Commands`'ta
komut ve kapı disiplini; `--no-verify` yok). Ayrıntı:
`bootstrap-prompt.md` §4–5.

Her klonda bir kez: backend'de `pip install pre-commit && pre-commit install`,
frontend'de sadece `npm install`. Bunu README'ye ve `manual-actions.md`'ye
yazmak bootstrap adımının işi.

## Gizlilik ve izinler

Üç katman var ve üçü farklı şeyi garanti ediyor — hangisinin ne yaptığını
bilmeden birine güvenmek asıl risk:

| Katman | Nerede | Ne yapar |
| --- | --- | --- |
| **Keşif** | `search.exclude`, `files.associations`, `github.copilot.enable`, `.gitignore` | Sır dosyalarını aramadan, workspace index'inden ve inline completion'dan çıkarır. Hedefli bir okumayı **durdurmaz** |
| **Eylem** | `chat.tools.terminal.autoApprove`, `chat.tools.edits.autoApprove`, `chat.agent.sandbox.enabled`, `permissions.deny` | Komutta ve düzenlemede onay kapısı. **Claude Code**'da `Read()`/`Edit()` deny gerçek blok — dosya araçlarını *ve* `cat`/`head`/`tail`/`sed` komutlarını kapsıyor. Sandbox, iki tarafta da tek OS düzeyi blok. Ajan kendi guardrail'ini genişletemez: `.claude/hooks/**` ve `.github/hooks/**` düzenlemeye kapalı, format hook'u da bu yolları hiç yazmıyor |
| **Prompt** | Golden rule: "sırlar okunmaz, yazdırılmaz, yapıştırılmaz" | Diğer ikisinin kapatamadığını kapatır |

**Sır düzeni bir sözleşmedir, liste değil.** Gerçek değerler `config/` altında ve
`.env*` dosyalarında yaşar; ikisi de asla okunmaz, asla düzenlenmez (iki
runtime'da da deny). Ajanın dokunduğu tek config dosyaları repo kökündeki
şablonlardır: `default.ini` ve `env.example` — yeni bir ayar oraya placeholder
değerle girer, adı `manual-actions.md`'ye yazılır, değerini insan doldurur.
Deny listesinin geri kalanı cerrahi: anahtar/sertifika, `secrets/**`,
`~/.ssh`, `~/.aws`, credential dosyaları.

İki sınır, çünkü **deny kuralı istisna kabul etmiyor**: şablonun adı `env.example`
(nokta ile başlasaydı `.env.*` kuralına yakalanır, geri açılamazdı); ve `config/`
bazı repolarda kaynak kodudur (`config/settings.py`) — bootstrap prompt o
durumda kuralı yalnız credential taşıyan dosyalara daraltır.

**Dürüst sınır:** GitHub'ın content exclusion özelliği Copilot'ın agent ve edit
modlarında uygulanmıyor ve Business/Enterprise istiyor. Copilot tarafında dosya
okumaya kesin bir blok yok; oradaki katman onay + keşif + prompt. Hiç
okunmaması gereken bir sır workspace'te değil, vault'ta durmalı.

## Skill'ler ve ajanlar

| Klasör | Skill | Ne yapar |
| --- | --- | --- |
| hepsi | `commit-and-pr` | Commit/PR formatı: İngilizce conventional başlık, Türkçe gövde |
| backend · frontend | `implement-task` | Bir isteği ya da `spec.md`'yi uçtan uca: anla → kur → kanıtla → kapılar → soğuk review (ajanlar) → `report.md` → PR; spec'ten çalışırken sorular rapora, commit yok |
| backend · frontend | `write-spec` | Geçmişsiz bir oturumun tahmin etmeden uygulayabileceği spec; tek spec'e sığmayan iş için `plan.md` (spec boyutunda görevler, her biri kendi doğrulamasıyla) |
| backend | `new-endpoint` · `db-migration` | Yığına özgü tarifler; `db-migration` deploy sırasını raporlar |
| frontend | `verify-ui` | Her UI değişikliğinde tarayıcı smoke: UI üzerinden ulaş, layout probe'ları, konsol, a11y, işlev uçtan uca → `ui-smoke.md` |
| frontend | `ui-check` | Yayın öncesi ekran × rol × viewport matrisi (`docs/screens.md`) → `ui-check.md` + `ui-bugs.md` |
| frontend | `new-component` · `impeccable` | Bileşen tarifi; tasarım kalitesi, `DESIGN.md`'ye karşı denetim (vendored) |
| analyst | `db-research` · `create-task` · `refine-task` · `update-db-catalog` | Salt-okunur DB araştırması, görev yazımı ve katalog |

Disiplin (kapılar, kök neden, ADR, soğuk review) skill değil, `AGENTS.md` kuralı:
her istekte yüklenir, tetiklenmeyi beklemez. Ajanlar (`.claude/agents/`, Claude formatı kanonik; `.github/agents/` ikizi
`sync-copilot-agents.py` ile üretilir ve klasörde hazır durur):
`code-reviewer` backend merceği (correctness → typing → boundaries → contract →
migrations → tests → complexity) ve frontend merceği (correctness → a11y →
i18n → conventions → TypeScript → tests → complexity); `security-reviewer`
(isolation → authorization → credentials/PII → abuse limits → cache revocation
→ browser surface → dependencies). Hepsi salt-okunur, soğuk okur, bulguları
`file:line · severity · issue · fix` biçiminde ve önem sırasıyla döner,
"possible" işaretini kullanır, `No findings.` diyebilir, kalan riski adlandırır.

## Tarayıcıda doğrulama

`verify-ui` ve `ui-check` runtime'a göre elindeki tarayıcıyı kullanır, sırayla:

1. **VS Code'un yerleşik tarayıcı araçları** — Copilot agent mode, VS Code
   1.127+. Harici MCP gerekmez.
2. **Claude in Chrome** — Claude Code + Chrome eklentisi; gerçek oturumla
   gerçek tarayıcı (giriş yapılmış ekranlar için en iyisi). Tuzaklar
   `verify-ui/references/chrome-notes.md`'de.
3. **Playwright MCP** — temiz ve script'lenebilir; akış e2e testine
   dönüşecekse tercih edilir.

Üçü de yoksa skill "doğrulayamadım" der, component testlerine düşer ve rapora
"browser smoke pending" yazar — "kanıtlandı" demez.

Ajansız taban ise **Playwright**: frontend profili `playwright.config.ts` +
`e2e/` getirir — `auth.setup.ts` (oturum, env'den), `screens.ts`
(`docs/screens.md`'yi okur; envanter tek kaynak), `probes.ts` (`probes.md`'deki
aynı kontroller), `smoke.spec.ts` (her rota × masaüstü/mobil: yükleme, beklenen
metin, konsol, ağ, üst üste binme, taşma, kaydırma, ekran görüntüsü).
`npm run test:e2e` CI'da da koşar; `verify-ui` ve `ui-check` işe onunla başlar,
script'in yargılayamadığı etkileşim, modal, rol ve dil adımlarını ajan ekler. Ekrana **UI üzerinden**
ulaşılır; URL yazarak ulaşılan ama menüden ulaşılamayan ekran bug'dır.

## docs/ taksonomisi

- `docs/engineering/` — **nasıl** inşa ediyoruz: mimari, yığın, konvansiyonlar,
  test, iş akışı, insanlara düşen işler.
- `docs/domain/` — **ne** inşa ediyoruz: sözlük, iş kuralları. Kararlı referans.
- `docs/decisions/` — **neden**: numaralı, değişmez ADR'lar. Kararla aynı PR'da.
- frontend ayrıca `docs/DESIGN.md` (tasarım sistemi) ve `docs/screens.md`
  (ekran envanteri).

## Token ve maliyet

1. **Önce kısa doküman.** `AGENTS.md` her istekte ödenir — ≤ ~150 satır, her
   skill ≤ ~80 satır; ayrıntı `references/`'a ya da linkli dokümana gider.
2. **Skill'ler gerektiğinde yüklenir.** İsabetli "ne zaman kullan" cümlesi
   eldeki en ucuz optimizasyondur.
3. **Yerleşik kod indeksi.** GitHub'da barındırılan depolar otomatik uzak
   semantik indeks alır. Lokal indeksleme ~2.500 dosyaya kadar iyi çalışır.
4. **Büyük depolar için MCP kod indeksi.** Gerekirse
   [claude-context](https://github.com/zilliztech/claude-context) veya
   [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp);
   benimsemeyi ADR olarak kaydet.
5. **Model karması.** Taslağı ucuz modelle yaz, review geçişini en güçlü
   modelle yap; Copilot'ta model seçici, Claude Code'da `/model`.

## Ne kullanıyoruz, ne kullanmıyoruz

Açık kaynak agent projeleri incelendi. Sonuç "hepsini kur" değil: **yalnız
biri kuruldu**, diğerlerinden kod değil fikir alındı.

| Proje | Karar | Neden |
| --- | --- | --- |
| **Impeccable** | kuruldu | Tasarım kalitesi boşluğunu dolduran tek aday; deterministik kurallar LLM'siz koşuyor, hook ve CI'a bağlanabiliyor. `frontend/.claude/skills/impeccable/`, ADR 0002 |
| **Karpathy skills** ([multica-ai](https://github.com/multica-ai/andrej-karpathy-skills)) | fikri alındı | Dört prensipten üçü Golden Rules'da zaten karşılanıyordu; gerçek boşluk iki maddeydi ve işlendi: alternatifleri sunma/itiraz kural #1'e, **cerrahi değişiklik testi** kural #4'e |
| **Ponytail** | fikri alındı | Merdiven altın kural #4'e, kök-neden kural #5'e yazıldı; `copilot-instructions.md` bizde bilinçli olarak yalnız işaretçi |
| **Superpowers** | yazım deseni alındı, eklenti kurulmadı | Iron law + red flags + ajanın bahanelerini önceden çürüten tablo — kapı disiplini ve kök-neden kuralı bu kalıpla yazıldı |
| **GSD Core** | mekanizması alındı, framework kurulmadı | 70+ skill ve kendi `.planning/` ağacı `AGENTS.md` ile ikinci doğruluk kaynağı olurdu; değerli üç mekanizması `write-spec`'in plan bölümüne sığdı |
| **Hallmark** | alınmadı | Impeccable ile aynı slot; çeşitlilik için tasarlanmış, üründe tutarlılık gerekiyor |
| **Caveman** | alınmadı | Kısa doküman politikasıyla çakışıyor |
| **Graphify** | sırada | Kod indeksi ihtiyacı doğmadı |

**Kaldırdıklarımız:** `start.py` (kopyalama artık `install.sh`, lint
hazırlık kontrolü bootstrap prompt §5'te) · `.ai/STATE.md` + `.ai/plans/`
(yerine `agent-work/<id>/`) · stack başına *farklı* skill metinleri (ortak skill'ler artık kelimesi
kelimesine aynı) · elle yazılan Copilot ajan ikizleri (üretiliyor) · şablon senkronizasyonu
sürüm damgası (yerine `diff-repo.sh`) · TR/EN şablon ikizliği · beş disiplin skill'i (`run-quality-gates`, `self-review`,
`debug-issue`, `record-decision`, `plan-feature`): kit ilkesi gereği skill yalnız
projeye özgü bilgi taşır; kapı disiplini `AGENTS.md → Commands`'a, kök neden kural
#5'e, ADR şablonu `docs/decisions/README.md`'ye, review dispatch'i `implement-task`'a,
plan `write-spec`'e taşındı — karmaşıklık taraması zaten `code-reviewer`'daydı.

## İlkeler (skill'ler yazılırken uyulan)

- **Ajanı yetenekli varsay.** Skill yalnız kararını değiştirecek, bu projeye
  özgü bilgiyi taşır; genel tavsiye yok.
- **Sonucu tarif et, yolu değil.** Sabit adım listesi yerine karar ölçütleri;
  katı adımlar yalnız sapmanın somut zarar verdiği yerde (migration, scope
  yüklemi, commit politikası, secret'lar).
- **Kanıt, iddia değil.** "Çalışıyor" demek için komut bu oturumda koşmuş ve
  çıktısı okunmuş olmalı.
- **Bloklanınca tahmin etme.** Geçmişsiz oturum soru soramaz: soru rapora
  yazılır, o kısım bırakılır.
- **Tek doğruluk kaynağı.** Aynı kural iki yerde yazılmaz: repo kuralı
  `AGENTS.md`'de, iş akışı burada, üretilebilen dosya elle yazılmaz.

## Dizin

```
ai-transformation/
  README.md · README_en.md · ai-coding-standardi.docx
  install.sh · diff-repo.sh · sync-copilot-agents.py
  bootstrap-prompt.md · bootstrap-prompt-greenfield.md
  backend/    ┐
  frontend/   ├ her biri o tip repoya kopyalanacak tam ağaç (aşağıda)
  analyst/    ┘
```

**`backend/`**

```
AGENTS.md · CLAUDE.md
.claude/   settings.json · hooks/{format-changed,remind-docs}.sh
           agents/{code-reviewer,security-reviewer}.md
           skills/ commit-and-pr · implement-task (+references/report.md) · write-spec (+references/task-spec.md)
                   new-endpoint · db-migration
.github/   copilot-instructions.md · agents/{code-reviewer,security-reviewer}.agent.md (üretilmiş)
           hooks/format-and-docs.json · workflows/copilot-setup-steps.yml
.vscode/   settings.json
.pre-commit-config.yaml · requirements-dev.txt
docs/      README.md · engineering/{architecture,tech-stack,conventions,testing,development-workflow,manual-actions}.md
           domain/{glossary,business-rules}.md · decisions/{README.md,0001-adopt-ai-driven-workflow.md}
```

**`frontend/`** — backend ile aynı omurga; farkları:

```
.claude/   skills/ … (+ verify-ui (+references/probes.md, chrome-notes.md) · ui-check · new-component · impeccable/)
           settings.json (impeccable hook'u da bağlı)
.github/   agents/ … + impeccable-*.agent.md (4, upstream) · hooks/ + impeccable.json
.vscode/   settings.json · mcp.json (Playwright)   ·   .mcp.json
.husky/pre-commit · .lintstagedrc.json · eslint.config.js · .prettierignore · .impeccable/.gitignore
playwright.config.ts · e2e/{auth.setup,screens,probes,smoke.spec}.ts
docs/      … + DESIGN.md · screens.md · decisions/0002-adopt-impeccable-design-quality.md
skill yok: new-endpoint, db-migration
```

**`analyst/`** — kod yok, kapı yok, reviewer yok:

```
AGENTS.md · CLAUDE.md
.claude/   settings.json · hooks/guard-readonly-sql.sh
           skills/ commit-and-pr · db-research · create-task · refine-task · update-db-catalog
.github/   copilot-instructions.md · hooks/guard-readonly.json
.vscode/   settings.json · mcp.json (DB sunucuları, parola VS Code input'u)   ·   .mcp.json
docs/      db-catalog.md · definition-of-done.md · how-analysts-work.md · task-template.md
tasks/     TASK-001-example-last-login-column.md
```
