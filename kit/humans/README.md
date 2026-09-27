# humans/ — insanlar için

Bu klasörü **insanlar** okur. Ajanlar istenmedikçe açmaz (kök ve kit ayarlarında okuma "sorar"); içerik token
yakmasın diye repolardan buraya taşınır.

| Klasör | Ne var |
|---|---|
| [`ai-standards/`](ai-standards/) | Ajan yapımız: [nasıl çalışır](ai-standards/nasil-calisir.md) · [nasıl kullanırız](ai-standards/nasil-kullaniriz.md) · [test planı](ai-standards/test-plani.md) |
| `<repo>/` | O repodan taşınan raporlar, sunumlar, araştırma notları (ihtiyaç oldukça açılır) |
| `archive/<repo>/` | Bilgi tabanına aktarılıp repodan kaldırılan eski belgeler. **Bakılmaz**; hiçbir belge buraya link vermez, doğrusu repo `docs/` ve `platform/`'da |

Kural: bir repoda yalnız ajanın işini yaparken okuduğu belgeler kalır (`AGENTS.md`, `docs/` bilgi tabanı, ADR'ler,
şema/güvenlik belgeleri). Rapor, sunum, demo senaryosu, araştırma notu buraya, `humans/<repo>/` altına gelir. 2 MB
üstü dosya git'e girmez (`link-repo.sh --kit --check` uyarır). Bayatlayan bir insan belgesi yeniden yazılmaz: başına
kısa bir "Güncel durum" notu eklenir, doğrusu repo `docs/`'ta.
