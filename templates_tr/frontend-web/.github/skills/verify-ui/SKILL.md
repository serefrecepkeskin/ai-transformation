---
name: verify-ui
description: Bir arayüz değişikliğini geliştirme sunucusu ve Playwright MCP sunucusu üzerinden gerçek tarayıcıda doğrular — ekran görüntüsü, konsol hataları, erişilebilirlik anlık görüntüsü, hesaplanmış stiller. Her bileşen/sayfa/stil değişikliğinden sonra, "yazıldı" demek yerine çalıştığını kanıtlamak için kullan.
---

# Arayüz değişikliğini tarayıcıda doğrula

> Playwright MCP sunucusu gerekir (`.vscode/mcp.json`). Mevcut değilse bunu
> söyle ve bileşen testlerine geri dön — arayüzün doğrulandığını iddia etme.

## Adımlar

1. Geliştirme sunucusunu başlat (AGENTS.md'nin Komutlar bölümüne bak), zaten
   çalışmıyorsa.
2. Playwright MCP tarayıcı araçlarıyla değişen sayfaya/duruma git.
3. Kanıt topla:
   - Değişen arayüzün **ekran görüntüsü** (ilgiliyse yükleniyor/hata durumları da).
   - **Konsol** — değişikliğin yol açtığı sıfır yeni hata/uyarı.
   - **Erişilebilirlik anlık görüntüsü** — değişen öğeler makul rol/ad sunuyor;
     etkileşimli öğelere erişilebiliyor.
   - Görsel/stil görevlerinde: kilit öğelerin hesaplanmış stilini görevin
     beklentisiyle karşılaştır.
4. Görevin konusu olan etkileşimi gerçekleştir (tıkla, yaz, gönder) ve kabul
   kriterlerinin gözle görülür şekilde sağlandığını doğrula.

## Notlar

- Değişikliğin dokunduğu her dil/tema varyantını doğrula.
- Kanıt özetini (ne kontrol edildi, ne görüldü) PR açıklamasına yapıştır —
  inceleyicinin kanıtı budur.
