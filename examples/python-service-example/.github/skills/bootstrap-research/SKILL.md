---
name: bootstrap-research
description: Bu kod tabanını araştırır ve AGENTS.md ile docs/ içindeki PLACEHOLDER alanlarını kanıtla doldurur — mimari, teknoloji yığını, konvansiyonlar, komutlar, test kurulumu. Şablon mevcut bir projeye kopyalandıktan sonra bir kez, ya da dokümanlarda hâlâ PLACEHOLDER/TODO(confirm) işaretleri kaldıysa kullan.
---

# Dokümanları gerçek kod tabanından doldur

`AGENTS.md` ve `docs/` içindeki her `PLACEHOLDER` alanını **bu depodan gelen
kanıtla** doldur — varsayımla asla. Doğrulayamadığın her şey insan için
`TODO(confirm): <soru>` olarak işaretli kalır.

## 1. Tara

- Manifest'ler: `pyproject.toml` / `requirements*.txt` / `setup.cfg`
  (framework, bağımlılıklar + sabitlenmiş sürümler), lockfile,
  `Makefile`/`noxfile`/script'ler.
- Yerleşim: paket yapısı, giriş noktaları, settings/config katmanı, modeller,
  router/view'lar, arka plan işleri.
- Veri: ORM + migration aracı (alembic/Django migrations), kullanılan DB motorları.
- CI: `.github/workflows/*` — gerçekte hangi kapılar çalışıyor. Dockerfile varsa.
- Mevcut docs/README — devral, tekrarlama.

## 2. Dosya dosya doldur

- `AGENTS.md` — proje özeti paragrafı + **Komutlar** bölümü (yalnız gerçek
  komutlar; var olmayanları sil).
- `docs/engineering/tech-stack.md` — kurulu sürümlerle yığın tablosu
  (lockfile'dan oku, tahmin etme).
- `docs/engineering/architecture.md` — servisin şekli, paket yerleşimi (gerçek
  ağaç), katmanlama, konfig/secret'ların nasıl yüklendiği, dış entegrasyonlar.
- `docs/engineering/conventions.md` — gözlemlenen isimlendirme, tipleme
  disiplini, lint/format araçları, hata yönetimi ve loglama desenleri.
- `docs/engineering/testing.md` — gerçek koşucular, klasör yerleşimi, CI kapıları.
- `docs/engineering/development-workflow.md` — CI konfiglerinden
  gözlemleyebildiğin dal/PR/release akışı.

## 3. Boşlukları işaretle

- Doğrulanamaz veya belirsiz → `TODO(confirm): <net soru>`.
- Yalnız bir insanın sağlayabileceği şeyler (kimlik bilgisi, dış spesifikasyon) →
  [manual-actions.md](../../../docs/engineering/manual-actions.md) dosyasına ekle.

## 4. Raporla

Özetle: hangi yer tutucular dolduruldu, `TODO(confirm)` listesi ne, ve
kod-konfig çelişkileri neler. Commit etme — diff'i ekibin incelemesi için bırak.
