# Mimari

> **PLACEHOLDER** — bunu gerçek kod tabanından doldurmak için
> `bootstrap-research` skill'ini çalıştır. Kısa tut; bir mimari karar
> değiştiğinde bu dosyayı güncelle ve aynı PR'da bir ADR yaz.

## Servisin şekli

TODO(confirm): API servisi / worker / batch — .NET sürümü, hosting modeli,
nasıl dağıtılıyor ve ölçekleniyor.

## Solution yapısı

```
TODO: gerçek proje ağacı (API / Domain / Infrastructure / Tests), tek satır
notlar ve izin verilen bağımlılık yönleriyle
```

## Katmanlar

- **API** — TODO: controller mı minimal API mı, DTO eşleme, middleware zinciri
- **Domain / servisler** — TODO
- **Veri erişimi** — TODO: EF Core DbContext'leri, yaşam süresi, repository
  deseni var mı
- **Konfig & secret'lar** — TODO: options deseni, environment/secret kaynakları
- **Arka plan işleri** — TODO: hosted service/kuyruklar, varsa

## Dış entegrasyonlar

TODO: yukarı/aşağı akış sistemler, kontratlar, hata durumundaki davranış.

## Dağıtım & sürüm

TODO(confirm): dal modeli, CI kapıları, bir merge nasıl sürüme/dağıtıma dönüşüyor.
