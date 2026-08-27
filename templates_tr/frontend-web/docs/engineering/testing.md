# Test

> **PLACEHOLDER** — gerçek koşucuları ve CI kapılarını doldurmak için
> `bootstrap-research` skill'ini çalıştır. Aşağıdaki klasör taksonomisi şirket
> standardıdır; koru.

## Test taksonomisi (klasörler sözleşmedir)

```
test/
├── unit/          # saf mantık (util, store, composable) — DOM yok, ms hızında
└── component/     # tek bileşenin davranışı — render et, etkileş, doğrula
e2e/               # Playwright — gerçek tarayıcıda kritik kullanıcı akışları
├── *.spec.ts      #   akış testleri; en hızlı kritik olanları @smoke etiketle
├── *-snapshots/   #   görsel regresyon baseline'ları (commit'li)
└── a11y.spec.ts   #   rota başına axe erişilebilirlik kapısı
```

- **unit** — fonksiyon/store verilen girdiyle beklendiği gibi döner/değişir.
- **component** — bileşen verilen prop/etkileşimle doğru şeyi gösterir
  (yükleniyor/boş/hata durumları dahil).
- **e2e** — kullanıcı kritik bir akışı tamamlar; `@smoke` alt kümesi deploy
  sonrası koşar.
- **görsel** — Playwright snapshot'ları istenmeyen arayüz regresyonlarını yakalar.
- **a11y** — axe her rotada geçmeli; yeni her renk/kontrol bunu geçer.

## Hangi değişiklik hangi testi yazar

| Değişiklik                  | Asgari gereken test                                   |
| --------------------------- | ----------------------------------------------------- |
| Yeni util/store mantığı     | unit                                                  |
| Yeni/değişen bileşen        | component (+ görünüm kritikse görsel)                 |
| Yeni sayfa veya akış adımı  | e2e (+ kritikse @smoke'a ekle)                        |
| Hata düzeltmesi             | önce başarısız test, hatayı üreten en alt katmanda    |
| Yeni rota                   | a11y kapısı kapsar                                    |

## Kurallar

- **Her task en az bir test getirir**; PR, kabul kriterlerini testlerle eşler
  ("kriter 2 → `test/component/UserList.spec.ts`").
- Hata düzeltmesi → önce hatayı yeniden üreten başarısız test, sonra düzeltme.
- Testler **çevrimdışı** koşar — dış çağrılar mock/fixture ile karşılanır.
- Arayüz değişiklikleri PR'da ayrıca tarayıcı kanıtı taşır (`verify-ui`).
- Kapılar yeşil olmadan merge yok (bkz. `run-quality-gates`).

## Komutlar & CI

TODO(confirm): katman başına gerçek komutlar ve PR'larda hangi workflow'un
hangi kapıları koştuğu.
