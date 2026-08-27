# Mimari Karar Kayıtları (ADR)

ADR'lar **numaralı ve değişmezdir**: değişen bir karar yeni bir ADR alır, eski
ADR `NNNN tarafından geçersiz kılındı` olarak işaretlenir. Dosya adı:
`NNNN-kebab-baslik.md`.

## ADR ne zaman yazılır?

- Bir framework/kütüphane/araç seçildiğinde veya değiştirildiğinde.
- Bir klasör yapısı ya da mimari desen netleştiğinde.
- Bir domain kuralı yorumu kodun içine gömüldüğünde.
- Geri dönüşü pahalı olacak herhangi bir yön belirlendiğinde.

> ADR, kodla ve etkilenen `engineering/`/`domain/` dokümanının
> güncellemesiyle **aynı PR içinde** gider. `record-decision` skill'ini kullan.

## İndeks

| #                                              | Başlık                       | Durum        |
| ---------------------------------------------- | ---------------------------- | ------------ |
| [0001](0001-adopt-ai-driven-workflow.md)       | AI-driven iş akışının benimsenmesi | Kabul edildi |
