# agent-kit

Bu workspace'in AI ajan yapısı: kurallar, skill'ler, reviewer ajanları, hook'lar ve PR kapısı tek yerde. Repolar
bunları kopyalamaz, **link** verir; `scripts/check-drift.sh` her şeyin yerinde olduğunu kanıtlar.

İnsanlar için kısa belgeler: [`humans/ai-standards/`](humans/ai-standards/) —
[nasıl çalışır](humans/ai-standards/nasil-calisir.md) · [nasıl kullanırız](humans/ai-standards/nasil-kullaniriz.md) ·
[test planı](humans/ai-standards/test-plani.md).

## Kurulum

```bash
mkdir <workspace> && cd <workspace>
git clone <bu reponun adresi> agent-kit      # klasör adı agent-kit olmalı
agent-kit/install.sh                         # root/workspace.conf'taki eksik repoları klonlar, hepsini bağlar
cd <workspace> && claude                     # ya da VS Code: workspace.code-workspace
```

Tekrar çalıştırmak güvenli (kit güncellenince, yeni repo gelince, link bozulunca). Yeni repo: `root/workspace.conf`'a
`repo <klasör> <backend|frontend>` satırı + `install.sh`.

## Roller ve akış

| Rol | Kim | Ne yapar |
|---|---|---|
| **Yürütücü** | Claude Code / Copilot (workspace kökünde) | İşi parçalar, `agent-work/<branch-slug>/spec.md` yazar, uygulatır, sonucu **bağımsız doğrular**, review turunu yürütür. Commit/push kullanıcı söylemeden yapılmaz |
| **Uygulayıcı** | aynı oturum, bir alt-ajan ya da Copilot coding agent | spec'i uygular, `report.md` yazar; bloklanırsa tahmin etmez, rapora soru yazar |
| **Gözden geçirici** | `backend-reviewer` / `frontend-reviewer` + `security-reviewer`, `/code-review`, `/security-review` | Diff'i soğuk okur, önem sıralı bulgu döner, dosya değiştirmez |
| **UI doğrulayıcı** | `verify-ui` (her değişiklik) · `ui-check` (sürüm öncesi) | Gerçek tarayıcıda kanıt: ekrana UI'dan ulaşma, taşma/üst üste binme, konsol, erişilebilirlik |

```
1. $write-spec          → agent-work/<branch-slug>/spec.md  (+ plan.md, birden çok oturumsa)
2. $implement-task      → rapor repo başına: agent-work/<branch-slug>/<repo>/report.md
3. doğrulama            → yürütücü diff'i okur, testleri kendisi koşar ("yeşil" raporu kanıt değildir)
4. KAPI                 → /simplify · /code-review · <profil>-reviewer · güvenlik (/security-review | security-reviewer)
                          bulgular + yapılanlar → agent-work/<branch-slug>/<repo>/review.md (## Gate bloğuyla)
5. UI değiştiyse        → $verify-ui
6. $commit-and-pr       → yalnız istenince; merge her zaman kullanıcıda
```

Claude Code'da `pr-gate` hook'u 4. adım bitmeden `git push` / `gh pr create`'i durdurur; Copilot ve insanlar için aynı
çizgiyi CI'daki `pr-evidence.yml` tutar.

## Dizin

```
platform/   AGENTS.md (kökte AGENTS.md/CLAUDE.md olarak linklenir) · principles.md · CLAUDE.md
skills/     write-spec implement-task review commit-and-pr new-endpoint db-migration verify-ui ui-check impeccable
agents/     backend-reviewer frontend-reviewer security-reviewer
hooks/      format-changed · remind-docs (+ oturum özeti) · pr-gate.sh → pr_gate.py · _changed.sh
scripts/    link-repo.sh (doğru kurulumun tanımı) · check-drift.sh · sync-copilot-agents.py
templates/  AGENTS.{backend,frontend}.md · settings.{backend,frontend,root,kit}.json · pr-evidence.yml ·
            task-spec / plan / report / review · repo.{backend,frontend}/ (repoya bir kez yazılan tohumlar)
root/       workspace.conf (araç + repo → profil) · README.md
humans/     insanlar için; ajanlar istenmedikçe okumaz
```

## Köken

Şirketin AI kodlama şablonundan (`ai-transformation`) üretildi. Kit'te bir şey değişecekse önce burada değişir,
şablona geri taşınması gerekenler şablon reposuna PR olarak gider.
