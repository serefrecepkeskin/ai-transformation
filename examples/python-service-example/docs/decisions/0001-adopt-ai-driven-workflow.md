# ADR 0001 — AI-driven iş akışının benimsenmesi

- **Durum:** Kabul edildi
- **Tarih:** 2026-08-20
- **Karar verenler:** orders-service ekibi + mühendislik liderliği

## Bağlam

Şirket, yapay zeka destekli geliştirmeyi GitHub Copilot üzerinde
standartlaştırıyor. Ajanların kararlı ve ucuz yüklenen bir bağlama ihtiyacı
var: kurallar, bilgi ve iş tarifleri kişilerin aklında veya kaybolan sohbet
geçmişlerinde durmamalı.

## Karar

Şirket şablonu benimsendi: kanonik `AGENTS.md` + `docs/` bilgi tabanı +
`.github/skills/` altındaki skill'ler + `code-reviewer` özel ajanı +
Copilot hook'ları. Dokümanlar kısa tutulur; yer tutucular `bootstrap-research`
ile bu depodan dolduruldu (2026-08-21); netleşen her karar aynı PR içinde bir
ADR'a dönüşür.

## Alternatifler

- Her geliştiricinin kendi serbest prompt'u — reddedildi: tutarsız çıktı,
  kalıcı bilgi yok.
- Tek dev talimat dosyası — reddedildi: her istekte pahalı, bakımı zor.

## Sonuçlar

- Yeni işler kabul kriterleri + DoD + test adımları taşıyan `task.md` olarak gelir.
- Doküman güncellemesi kodla aynı PR'da gider; drift hook'la hatırlatılır.
