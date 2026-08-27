# ADR 0001 — AI-driven iş akışının benimsenmesi

- **Durum:** Kabul edildi
- **Tarih:** TODO
- **Karar verenler:** TODO

## Bağlam

Şirket, yapay zeka destekli geliştirmeyi GitHub Copilot üzerinde
standartlaştırıyor. Ajanların kararlı ve ucuz yüklenen bir bağlama ihtiyacı
var: kurallar, bilgi ve iş tarifleri kişilerin aklında veya kaybolan sohbet
geçmişlerinde durmamalı.

## Karar

Şirket şablonu benimsendi: kanonik `AGENTS.md` + `docs/` bilgi tabanı
(engineering / domain / decisions) + `.github/skills/` altındaki skill'ler +
`code-reviewer` özel ajanı. Dokümanlar bilinçli olarak kısa tutulur (token
maliyeti); yer tutucular `bootstrap-research` skill'i ile gerçek kod tabanından
doldurulur; netleşen her karar aynı PR içinde bir ADR'a dönüşür.

## Alternatifler

- Her geliştiricinin kendi serbest prompt'u — reddedildi: tutarsız çıktı,
  kalıcı bilgi yok.
- Tek dev talimat dosyası — reddedildi: her istekte pahalı, bakımı zor;
  skill'ler bunun yerine gerektiğinde yüklenir.

## Sonuçlar

- Yeni işler, kabul kriterleri + DoD + nasıl test edileceği bilgisini taşıyan
  bir `task.md` olarak gelmek zorunda (analist workspace şablonu).
- Dokümanlar ve kod birbirinden kopmamalı: doküman güncellemesi aynı PR'da gider.
