# Geliştirme Akışı

```
task.md → dal → geliştir → doğrula → öz-inceleme → PR → CI kapıları → merge → dağıtım
```

1. **İşi al** — işler `task.md` olarak gelir (analist workspace'inden).
   `implement-task` skill'i tüm akışı yürütür. Kabul kriterleri / DoD / nasıl
   test edilir taşımayan görev geri gönderilir.
2. **Dal aç** — taze main'den: `<tip>/<kebab-aciklama>`,
   ör. `feat/TASK-214-siparis-iptal-endpointi`.
3. **Geliştir** — en küçük diff; endpoint için `new-endpoint`, şema için
   `db-migration`. Netleşen kararlar anında ADR olur (`record-decision`).
4. **Doğrula** — testler + endpoint'i lokalde çağır (`uv run uvicorn ...`);
   kapılar lokalde yeşil (`run-quality-gates`).
5. **Öz-inceleme** — istersen önce `simplify`, sonra `self-review`;
   kritik/orta bulgular düzeltilir.
6. **PR** — conventional-commit başlık; açıklamada ne değişti, test kanıtı,
   öz-inceleme sonucu, kriter↔test eşlemesi.
7. **Merge & dağıtım** — squash-merge; CI yeşilse test ortamı otomatik
   yeniden kurulur, prod platform arayüzünden manuel terfidir.
8. **Merge sonrası** — main'i çek, sıradaki görevi taze bir daldan başlat.
