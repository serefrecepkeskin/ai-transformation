---
name: commit-and-pr
description: Commit'leri ve PR/MR başlık-açıklamalarını şirket formatında yazar — İngilizce conventional-commit başlık, kanıtı taşıyan Türkçe gövde/açıklama. Bir işi commit'lerken ya da pull/merge request açarken kullan.
---

# Commit & PR formatı

## Commit

- **Başlık (1. satır): İngilizce, conventional commit** —
  `type(scope): emir kipinde özet`, ≤ 72 karakter, sonda nokta yok.
  Tipler: `feat|fix|chore|docs|refactor|perf|test|ci|build|revert`.
- **Gövde: Türkçe** — değişiklik neden yapıldı ve kayda değer karar ne,
  2-5 kısa satır. Gövde yalnız önemsiz değişikliklerde atlanır.
- Commit başına tek mantıksal değişiklik; refactor ile davranış değişikliği
  asla karışmaz.

```
feat(orders): add cancel endpoint

Kargolanmamış siparişin iptali için endpoint eklendi. İptalde stok
iadesi servis katmanında yapılıyor; kural business-rules.md'de.
```

## PR / MR

- **Başlık: aynı İngilizce conventional commit** — squash merge ile yayınlanan
  commit o olur.
- **Açıklama: Türkçe**, şu bölümlerle:
  - **Ne değişti** — 2-4 cümle, çözümün özeti.
  - **Nasıl doğrulandı** — test/tarayıcı kanıtı; kabul kriteri ↔ test eşlemesi.
  - **Self-review** — bulgular ve ne yapıldığı.
  - **Notlar** — ilgili ADR'lar, açık sorular, bilinçli atlanmış işler.
- İş bir `task.md`'den geldiyse görevin DoD listesi açıklamada işaretlenir.
