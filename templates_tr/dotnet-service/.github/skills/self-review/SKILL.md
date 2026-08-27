---
name: self-review
description: Commit/push/PR öncesi yerel yapay zeka öz-incelemesi — code-reviewer ajanı diff'i denetler ve bulguları önem sırasına göre döndürür. Bir değişikliği yukarı göndermeden önce mutlaka çalıştır.
---

# Diff'i öz-incele

## Adımlar

1. Denetlenecek diff'i belirle: commit'lenmemiş değişiklikler ya da dal zaten
   commit içeriyorsa `main..HEAD`.
2. O diff üzerinde **`code-reviewer`** özel ajanını
   (`.github/agents/code-reviewer.agent.md`) çalıştır. İnceleme adımında,
   değişiklik daha ucuz bir modelle yazılmış olsa bile mevcut en güçlü modeli
   tercih et.
3. Tüm **kritik** ve **orta** bulguları düzelt; düzeltilmeyenleri PR
   açıklamasında belirt.
4. Düzeltmelerden sonra `run-quality-gates` skill'ini tekrar çalıştır.

## Not

- İnceleyicinin "olası" diye işaretlediği bulgular önce doğrulanır —
  tahmin üzerine diff'i oynatma.
