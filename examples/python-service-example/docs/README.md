# docs/ — bilgi tabanı

Bu klasör neden var: `AGENTS.md` her istekte ajanın bağlamına yüklenir, bu
yüzden kısa kalmak zorundadır. Her seferinde bedeli ödenmesi gerekmeyen her
şey burada yaşar ve yalnız bir görev gerektirdiğinde okunur. İnsanlar ve
ajanlar aynı doğru kaynağı paylaşır.

| Klasör         | Cevapladığı soru       | Güncelleme kuralı                                  |
| -------------- | ---------------------- | -------------------------------------------------- |
| `engineering/` | **Nasıl** inşa ediyoruz | onu etkileyen değişiklikle birlikte, aynı PR'da    |
| `domain/`      | **Ne** inşa ediyoruz    | yalnız kavram ilk tanımlandığında ya da değiştiğinde |
| `decisions/`   | **Neden** böyle         | yalnız eklenen numaralı ADR'lar; eskiler düzenlenmez |

Temel kurallar: her dosya kısa kalır; doküman güncellemesi anlattığı kodla
aynı PR'da gider; netleşmemiş bilgiler tahmin edilmez, `TODO(confirm)` ile
işaretlenir.
