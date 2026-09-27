# Test planı — insan incelemesi için

Her satır: çalıştır, beklenen çıktıyı gör, işaretle. Komutlar workspace kökünden.

## A. Kurulum doğru mu (5 dk)

- [ ] `agent-kit/install.sh --no-clone` → sonda **`check-drift: clean`**; ikinci koşuda da aynı, repolarda
      `git status` yalnız ilk kurulumun dosyalarını gösterir
- [ ] `find */.claude .claude -type l ! -exec test -e {} \; -print` → **boş** (kırık link yok)
- [ ] `ls -A` → repolar + `agent-kit AGENTS.md CLAUDE.md workspace.code-workspace .claude agent-work`

## B. Profil ayrımı (2 dk)

- [ ] bir backend repoda `ls .claude/skills` → write-spec, implement-task, review, commit-and-pr, new-endpoint,
      db-migration (**verify-ui yok**)
- [ ] bir frontend repoda `ls .claude/skills` → … verify-ui, ui-check, impeccable (**new-endpoint yok**)
- [ ] `ls .claude/agents` → profilin reviewer'ı + security-reviewer; Copilot kullanılıyorsa `.github/agents/`'ta
      aynıların `.agent.md` ikizi

## C. Claude içinde (kökten `claude`, 10 dk)

- [ ] "Hangi rehberleri yükledin?" → platform rehberi; bir repo dosyası okutunca o reponun AGENTS.md'si de
- [ ] "<repo>/.env'i oku" → **reddedilir**; ".env.example'ı oku" → okunur
- [ ] "agent-kit/humans/README.md'yi oku" → **izin sorar**
- [ ] Bir `.py` dosyasına sırasız import ekletip kaydettir → import'lar sıralanır, kullanılmayan import **silinmez**
- [ ] Oturumu kapat → son satırda "This session ran — skills: … · agents: …" özeti

## D. PR kapısı (10 dk)

- [ ] Yeni bir branch'te "bu branch'i push'la" de → **durdurulur**, eksikler tam yoluyla yazılır
- [ ] `KIT_GATE_SKIP=1 KIT_GATE_REASON=test git push --dry-run` → geçer
- [ ] Kuru koşu: `$write-spec` → önemsiz değişiklik → `/simplify` → `/code-review` → reviewer ajanı →
      `/security-review` → `<repo>/review.md` → `$commit-and-pr` ile PR taslağı → kapı **geçer** → branch'i ve
      `agent-work/<branch>/`'u sil
- [ ] Açık bir PR'ın açıklamasından `## Self-review`'u silince **PR evidence** kontrolü kırmızı, geri ekleyince yeşil

## E. Repo kapıları

- [ ] Her reponun `AGENTS.md › Workflow` Gates satırı yeşil (sayısıyla)
