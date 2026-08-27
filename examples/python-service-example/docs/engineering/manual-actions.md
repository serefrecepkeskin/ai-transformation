# Manuel Aksiyonlar — İnsan Kontrol Listesi

> **İnsan gerektiren işlerin** tek doğru kaynağı. İş bitince kutucuk
> işaretlenir ve kısa bir notla _Tamamlandı_ bölümüne taşınır.

## Bekleyen — aksiyon gerekiyor

- [ ] **Ödeme sağlayıcısı sandbox anahtarı** — `PAID` geçişinin gerçek
      entegrasyonu için gerekiyor; anahtar gelene kadar geçiş BFF onayıyla
      simüle ediliyor (bkz. architecture.md "Dış entegrasyonlar").
- [ ] **Kısmi iade kuralının teyidi** — iş tarafı kısmi iadenin hangi
      statülerde mümkün olduğunu netleştirmedi
      (bkz. business-rules.md TODO(confirm)).
- [ ] **Staging DB salt okunur kullanıcısı** — analist workspace'inin
      db-research erişimi için DBA ekibinden istendi.

## Tamamlandı

- [x] **Container platformunda test/prod uygulamaları** — health check
      `/health`, port 8000; test otomatik, prod manuel terfi.
