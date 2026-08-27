---
name: new-component
description: Bu deponun konvansiyonlarına uyan yeni bir arayüz bileşeni oluşturur — TypeScript, proje isimlendirmesi, stil yaklaşımı, kullanıcıya görünen tüm metin için i18n, test id kancaları. Buton/kart/dialog/form bölümü gibi bir bileşen eklerken kullan.
---

# Yeni bileşen

Önce [conventions.md](../../../docs/engineering/conventions.md) dosyasını oku —
doğru kaynak odur. PLACEHOLDER: bootstrap-research sonrası bu skill, deponun
gerçek bileşen konumunu, isimlendirme stilini ve stil sistemini yazmalı.

## Kurallar

- **Konum & isimlendirme** — mevcut bileşen dizinine ve isim şemasına birebir
  uy (dosyayı oluşturmadan önce komşularına bak).
- **TypeScript strict** — tipli prop'lar, `any` yok.
- **Önce yeniden kullan** — yenisini eklemeden önce bu işi zaten yapan bir
  bileşen/varyant var mı diye ara.
- **Stil** — projenin tasarım token'ları/varyant sistemi; hardcoded renk veya
  sihirli piksel değeri yok.
- **İçerik** — kullanıcıya görünen metin i18n'den; bileşenler içeriği prop/slot
  ile alır, gömülü string ile değil.
- **Erişilebilirlik** — semantik öğeler, klavyeyle erişilebilirlik, etkileşimli
  kontroller için etiketler.
- **Test edilebilirlik** — E2E hedefi olan öğelere `data-testid` ekle.
- **Doğrula** — uygulamada render et ve `verify-ui` skill'ini çalıştır;
  davranış için bir bileşen testi ekle.
