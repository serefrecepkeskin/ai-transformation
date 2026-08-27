---
name: bootstrap-research
description: Bu kod tabanını araştırır ve AGENTS.md ile docs/ içindeki PLACEHOLDER alanlarını kanıtla doldurur — mimari, teknoloji yığını, konvansiyonlar, komutlar, test kurulumu. Şablon mevcut bir projeye kopyalandıktan sonra bir kez, ya da dokümanlarda hâlâ PLACEHOLDER/TODO(confirm) işaretleri kaldıysa kullan.
---

# Dokümanları gerçek kod tabanından doldur

`AGENTS.md` ve `docs/` içindeki her `PLACEHOLDER` alanını **bu depodan gelen
kanıtla** doldur — varsayımla asla. Doğrulayamadığın her şey insan için
`TODO(confirm): <soru>` olarak işaretli kalır.

## 1. Tara

- Manifest'ler: `package.json` (ad, script'ler, bağımlılıklar + sürümler),
  lockfile (paket yöneticisi), `tsconfig`, framework konfigü
  (next.config, vite.config, ...).
- Yerleşim: üst seviye klasörler, bileşen/sayfa/store/api dizinleri, test dizinleri.
- CI: `.github/workflows/*` — gerçekte hangi kapılar çalışıyor.
- Mevcut docs/README — devral, tekrarlama.

## 2. Dosya dosya doldur

- `AGENTS.md` — proje özeti paragrafı + **Komutlar** bölümü (yalnız gerçek
  script adları; var olmayan komutları sil).
- `docs/engineering/tech-stack.md` — kurulu sürümlerle yığın tablosu
  (lockfile/package.json'dan oku, tahmin etme).
- `docs/engineering/architecture.md` — render stratejisi, klasör yapısı
  (gerçek ağaç), katmanlar, kodda bulunan state/veri çekme yaklaşımı.
- `docs/engineering/conventions.md` — gözlemlenen isimlendirme, stil
  yaklaşımı, i18n mekanizması, lint/format araçları. Kod ile konfig
  çelişiyorsa not düş.
- `docs/engineering/testing.md` — gerçek test koşucuları, klasör yerleşimi, CI kapıları.
- `docs/engineering/development-workflow.md` — CI konfiglerinden gözlemleyebildiğin
  dal/PR/release akışı.

## 3. Boşlukları işaretle

- Doğrulanamaz veya belirsiz → `TODO(confirm): <net soru>`.
- Yalnız bir insanın sağlayabileceği şeyler (secret, dış spesifikasyon) →
  [manual-actions.md](../../../docs/engineering/manual-actions.md) dosyasına ekle.

## 4. Raporla

Özetle: hangi yer tutucular dolduruldu, `TODO(confirm)` listesi ne, ve
kod-konfig çelişkileri neler. Commit etme — diff'i ekibin incelemesi için bırak.
