# AI Dönüşümü — Şirket Agent Kit'i

> English version: [README_en.md](README_en.md) · Gerekçe belgesi:
> [`humans/ai-coding-standardi-v2.docx`](humans/ai-coding-standardi-v2.docx) · Ekibe anlatım sunumu:
> [`sunum.html`](sunum.html) (tarayıcıda aç)

AI destekli geliştirmenin ortak yapısı. **Tek şablon, iki araç:** aynı skill ve ajan tanımlarını Claude Code ve
GitHub Copilot okur. `install.sh` hedefe bakar ve üç şeyden birini kurar:

| Hedef | Nasıl anlar | Ne kurar |
|---|---|---|
| **Tek frontend repo** | `package.json` | Kit dosyaları reponun içine **kopyalanır**: skill'ler, reviewer ajanları, hook'lar, izinler, PR kapısı, `docs/` bilgi tabanı, commit kapısı (husky + lint-staged), Playwright e2e iskeleti, Copilot dosyaları |
| **Tek backend repo** | `pyproject.toml` / `requirements*.txt` / `setup.py` | Aynısı, backend profiliyle: `new-endpoint`, `db-migration`, pre-commit kapısı |
| **Workspace** | alt klasörleri git reposu olan bir klasör | Workspace'in yanına kendi **`agent-kit` reposunu** oluşturur (bu şablondan), kökü kurar ve her repoyu profiline göre kit'e **link**'ler — kurallar ve araçlar tek yerde, tüm repolarda aynı |

## Kurulum

```bash
git clone <bu reponun adresi> ~/kod/ai-transformation
~/kod/ai-transformation/install.sh ~/kod/musteri-portali      # bir workspace (birden çok repo)
~/kod/ai-transformation/install.sh ~/kod/servis-repo          # tek repo — profili manifest'ten anlar
~/kod/ai-transformation/install.sh ~/kod/yeni-repo --new      # boş repo: sıfırdan proje prompt'u
```

Script sorar: hedef türü ve profil (manifest'ten tahmin eder), hangi AI aracı (`claude` / `copilot` / `both`),
workspace'te her reponun profili (`backend` / `frontend` / `skip`). Sormadan kurmak için `--yes`, `--tool`,
`--profile`, `--kit-remote <url>`. Var olan dosyaya dokunmaz; tekrar çalıştırmak güvenlidir. Sonunda ekrana
**bootstrap prompt**'unu basar — onu ajana yapıştırırsın; ajan `AGENTS.md` ve `docs/` içindeki her `PLACEHOLDER`'ı
gerçek koddan doldurur, doğrulayamadığını `TODO(confirm)` olarak bırakır, kalite kapısını bağlar.

**Workspace kurulumundan sonra:** `agent-kit/` yeni bir git reposudur — ekibin git sunucusunda bir repo aç ve push'la
(`git -C agent-kit remote add origin <url> && git -C agent-kit push -u origin main`). Ekip arkadaşların şablona
dokunmaz: `mkdir <workspace> && cd <workspace> && git clone <agent-kit adresi> agent-kit && agent-kit/install.sh`
eksik repoları klonlar ve her şeyi bağlar.

Kontrol: `install.sh <hedef> --check` (tek repoda kopyaları kit'le bayt bayt karşılaştırır, workspace'te
`agent-kit/scripts/check-drift.sh`'yi koşar) → `check-drift: clean`.

## Nasıl çalışılır — bir görev, 6 adım

```
1. $write-spec          → agent-work/<branch-slug>/spec.md  (+ plan.md, birden çok oturumsa)
2. $implement-task      → rapor repo başına: agent-work/<branch-slug>/<repo>/report.md
3. doğrulama            → yürütücü diff'i okur, testleri kendisi koşar ("yeşil" raporu kanıt değildir)
4. KAPI                 → /simplify · /code-review · <profil>-reviewer · güvenlik (/security-review | security-reviewer)
                          bulgular → agent-work/<branch-slug>/<repo>/review.md
5. UI değiştiyse        → $verify-ui
6. $commit-and-pr       → yalnız istenince; merge her zaman insanda
```

- **PR kapısı:** Claude Code'da bir hook, 4. adım oturumda gerçekten koşmadan `git push` / `gh pr create`'i durdurur;
  Copilot ve insanlar için aynı çizgiyi her repoya kurulan CI kontrolü `pr-evidence.yml` tutar (PR açıklamasında
  "Nasıl doğrulandı" ve "Self-review" ister). Bilinçli istisna: `KIT_GATE_SKIP=1 KIT_GATE_REASON=<neden>`, log'lanır.
- **İz:** `agent-work/` hiç commit'lenmez; workspace'te kökte, tek repoda reponun içinde (`.gitignore`'da).
- **12 mühendislik prensibi** her oturumda yüklenir (workspace'te kök `AGENTS.md`, tek repoda
  `docs/engineering/principles.md`). İlk beşi Andrej Karpathy'nin LLM ile kod yazma prensiplerini taşır: önce düşün,
  "bitti"yi tanımla ve kanıtla, kapılar yeşil, basitlik merdiveni, cerrahi değişiklik; ardından kök neden, test,
  sınırda doğrulama, sırlar, insana kalan işler, ADR, başkasına ait metinler.

## Tek repo mu, workspace mi

| | Tek repo | Workspace |
|---|---|---|
| Kit dosyaları | repoya **kopya** (`.claude/`) | `agent-kit/`'e **link** — bir değişiklik tüm repolara yansır |
| Kurallar | `docs/engineering/principles.md` + repo `AGENTS.md` | kök `AGENTS.md` (platform rehberi: repo haritası, ortak veri, branch'ler, prensipler) + repo `AGENTS.md` |
| Claude nereden başlar | repo kökünden | **workspace kökünden** — kök ayarları (izinler, hook'lar, kapı) tüm repolara uygulanır |
| Güncelleme | şablonu çek → `install.sh <repo> --refresh` (kit'e ait kopyaları yeniler); `--check` farkı gösterir | kit'i güncelle → `agent-kit/install.sh --refresh`; `check-drift.sh` |
| Ne zaman | tek başına yaşayan repo; Copilot coding agent (bulut) | birbirine dokunan repolar: API + panel + worker … |

**Sınırlar:** Copilot coding agent (bulut) tek repoyu klonlar; kardeş klasördeki `agent-kit`'e giden link'ler orada
boştur — o repoyu tek-repo modunda kur. Windows'ta symlink Developer Mode + `git config core.symlinks true` ister;
yoksa tek-repo modu. Kök `.claude/settings.json` yalnız Claude kökten başlatılınca geçerlidir.

## Rollerin sözleşmesi

| Rol | Kim | Ne yapar |
|---|---|---|
| **Yürütücü** | geliştiricinin Claude Code / Copilot oturumu | İşi parçalar, spec yazar, uygular ya da devreder, sonucu **bağımsız doğrular**, review turunu yürütür. Commit/push kullanıcı söylemeden yapılmaz |
| **Uygulayıcı** | aynı oturum, bir alt-ajan ya da Copilot coding agent | spec'i uygular, `report.md` yazar; bloklanırsa tahmin etmez, rapora soru yazar; commit etmez |
| **Gözden geçirici** | `backend-reviewer` / `frontend-reviewer` + `security-reviewer`, `/code-review`, `/security-review` | Diff'i soğuk okur (amaç var, anlatım yok), önem sıralı bulgu döner, dosya değiştirmez |
| **UI doğrulayıcı** | `verify-ui` (her değişiklik) · `ui-check` (sürüm öncesi) | Gerçek tarayıcıda kanıt: ekrana UI'dan ulaşma, taşma/üst üste binme, konsol, erişilebilirlik, işlev |

## Ne kullanıyoruz, ne kullanmıyoruz

| Proje | Karar | Neden |
| --- | --- | --- |
| **Impeccable** | kuruldu | Tasarım kalitesi boşluğunu dolduran tek aday; deterministik kuralları LLM'siz koşar (frontend profili, ADR 0002) |
| **Karpathy skills** ([multica-ai](https://github.com/multica-ai/andrej-karpathy-skills)) | fikri alındı | Dört prensip 12 prensibin ilk beşine işlendi (itiraz et, cerrahi değişiklik testi) |
| **Ponytail** | fikri alındı | Basitlik merdiveni ve kök-neden kuralı |
| **Superpowers** | yazım deseni alındı | Iron law + red flags + bahaneleri önceden çürüten tablo — kapı disiplini bu kalıpla yazıldı |
| **GSD Core** | mekanizması alındı | Plan dosyası, taze oturuma devir, ship öncesi uçtan uca yürüyüş → `write-spec` |
| **Hallmark · Caveman** | alınmadı | Impeccable ile aynı slot · kısa doküman politikasıyla çakışıyor |

## İlkeler (kit yazılırken uyulan)

- **Skill yalnız ajanın kararını değiştirecek bilgiyi taşır**; genel disiplin her istekte yüklenen prensiplerdedir.
- **Repo bilgisi repo `AGENTS.md`'sindedir** (8 sabit başlık); skill'ler kit'e aittir ve oradan okur.
- **Kanıt, iddia değil** — "çalışıyor" için komut bu oturumda koşmuş ve çıktısı okunmuş olmalı.
- **Tek doğruluk kaynağı** — aynı kural iki yerde yazılmaz; üretilebilen dosya (Copilot ikizleri, workspace dosyası)
  elle yazılmaz; `check-drift` bunu kanıtlar.

## Dizin

```
ai-transformation/
  install.sh                        tek giriş: hedefi tarar, sorar, kurar (--check: drift raporu)
  bootstrap-prompt.md               var olan repo / workspace için: PLACEHOLDER'ları koddan doldur
  bootstrap-prompt-greenfield.md    boş repo için: önce karar, sonra iskelet
  kit/                              workspace'te <workspace>/agent-kit olur; tek repoda parça parça kopyalanır
    platform/  skills/  agents/  hooks/  scripts/  templates/  root/  humans/
  tests/selftest.sh                 üç hedefi geçici klasörlerde kurar ve doğrular (CI'da da koşar)
  humans/                           şablonun kendi insan belgeleri (v1 gerekçe belgesi)
```

Kit'in iç yapısı ve her repoda hangi dosyanın ne işe yaradığı:
[`kit/humans/ai-standards/nasil-calisir.md`](kit/humans/ai-standards/nasil-calisir.md).

## v1'den geçiş

v1 üç kopya profil klasörüyle (`backend/`, `frontend/`, `analyst/`) ve `install.sh <profil> <repo>` çağrısıyla
çalışıyordu. Artık `install.sh <repo>` profili kendisi anlar (`--profile` ile verilebilir); analist profili kalktı.
v1 ile kurulmuş bir repoda: `install.sh <repo>` eksik kit dosyalarını ekler; v1'in `.claude/skills` kopyaları kit'le
farklıysa `--check` bunları `drift` olarak gösterir — silip yeniden çalıştır. `agent-work/` artık commit'lenmez.
