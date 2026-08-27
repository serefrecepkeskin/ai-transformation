# Mimari

> **PLACEHOLDER** — bunu gerçek kod tabanından doldurmak için
> `bootstrap-research` skill'ini çalıştır. Kısa tut; bir mimari karar
> değiştiğinde bu dosyayı güncelle ve aynı PR'da bir ADR yaz.

## Servisin şekli

TODO(confirm): API servisi / worker / batch — framework, giriş noktaları,
nasıl dağıtılıyor ve ölçekleniyor.

## Paket yapısı

```
TODO: modül başına tek satır notla gerçek paket ağacı
```

## Katmanlar

- **API / router'lar** — TODO: endpoint'ler nerede, request/response modelleri
- **Servisler / domain mantığı** — TODO
- **Veri erişimi** — TODO: ORM, session yönetimi, repository deseni var mı
- **Konfig & secret'lar** — TODO: settings katmanı, env yönetimi
- **Arka plan işleri** — TODO: kuyruk/zamanlayıcı, varsa

## Dış entegrasyonlar

TODO: yukarı/aşağı akış sistemler, kontratlar, hata durumundaki davranış.

## Dağıtım & sürüm

TODO(confirm): dal modeli, CI kapıları, bir merge nasıl sürüme/dağıtıma dönüşüyor.
