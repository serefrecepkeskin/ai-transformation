---
name: commit-and-pr
description: Writes commits and PR/MR titles and descriptions in the company format — English conventional-commit title, Turkish body/description carrying the evidence. Use whenever committing work or opening a pull/merge request.
---

# Commit & PR format

## Commit

- **Title (line 1): English, conventional commit** —
  `type(scope): imperative summary`, ≤ 72 chars, no trailing period.
  Types: `feat|fix|chore|docs|refactor|perf|test|ci|build|revert`.
- **Body: Turkish** — why the change was made and any noteworthy decision,
  2-5 short lines. Skip the body only for trivial changes.
- One logical change per commit; never mix refactor with behavior change.

```
feat(orders): add cancel endpoint

Kargolanmamış siparişin iptali için endpoint eklendi. İptalde stok
iadesi servis katmanında yapılıyor; kural business-rules.md'de.
```

## PR / MR

- **Title: the same English conventional commit** — squash merge makes it the
  released commit.
- **Description: Turkish**, with these sections:
  - **Ne değişti** — 2-4 cümle, çözümün özeti.
  - **Nasıl doğrulandı** — test/tarayıcı kanıtı; kabul kriteri ↔ test eşlemesi.
  - **Self-review** — bulgular ve ne yapıldığı.
  - **Notlar** — ilgili ADR'lar, açık sorular, bilinçli atlanmış işler.
- Check off the task's DoD list in the description when the work came from a
  `task.md`.
