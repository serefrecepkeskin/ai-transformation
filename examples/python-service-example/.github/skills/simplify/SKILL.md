---
name: simplify
description: Değişen kodu yeniden kullanım, sadeleştirme ve ölü ağırlık açısından inceler, güvenli temizlikleri uygular — yalnız kalite işidir, bug avlamaz (onu self-review yapar). İş çalışır hale geldikten sonra, self-review/PR öncesinde kullan.
---

# Değişikliği sadeleştir

Kapsam: yalnız mevcut diff (commit'lenmemiş değişiklikler ya da `main..HEAD`).
Görevin dokunmadığı kodu asla "iyileştirme" (AGENTS.md: cerrahi değişiklik).

## Neye bakılır

- **Yeniden icat** — bu depoda zaten var olan bir util/bileşen/yardımcının
  yeniden yazılmış hali. Mevcut olanla değiştir.
- **Gereksiz soyutlama** — görevde olmayan bir gelecek için eklenmiş
  katman/arayüz/opsiyon. İçine al (inline).
- **Ölü ağırlık** — kullanılmayan import/prop/dal, yorum satırına alınmış kod,
  debug kalıntıları, tek fonksiyon olması gereken kopyala-yapıştır bloklar.
- **Daha basit eşdeğer** — aynı davranış daha az parçayla (iç içe blok yerine
  erken dönüş, elle yazılmış yerine yerleşik fonksiyon).

## Kurallar

1. Davranış değişmemeli — bu bir refactor geçişidir, yeniden tasarım değil.
   Bir sadeleştirme davranışı değiştirecekse uygulama, not düş.
2. Güvenli düzeltmeleri doğrudan uygula; atlananları nedeniyle listele.
3. Uyguladıktan sonra `run-quality-gates` tekrar koş — testi kıran
   sadeleştirme geri alınır, etrafından dolaşılmaz.
4. Sonra `self-review`e geç. Kayda değer sadeleştirmeleri PR açıklamasında an.
