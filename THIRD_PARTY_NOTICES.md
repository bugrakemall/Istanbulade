# Kaynak ve lisans kayıtları

## Harita verisi — OpenStreetMap

© OpenStreetMap katkıcıları. Open Database License (ODbL) 1.0.

- Kaynak ve atıf: https://www.openstreetmap.org/copyright
- Lisans: https://opendatacommons.org/licenses/odbl/1-0/
- Veri alımı: Overpass API, 18 Ekim 2026.
- Sokak ve park sınırları: güney 40.985, batı 28.93, kuzey 41.06, doğu 29.045. Kıyılar için biraz daha geniş kesit kullanıldı.
- İşlenmiş veri: `ios/assets/map-data.json`, ODbL 1.0 altında dağıtılır. Koordinat dönüşümü dosyanın `projection` alanında yazılıdır. Uygulama kodu bu veriden ayrıdır.
- Harita tasarımı, renkleri, simgeleri ve çizici kodu bu proje için hazırlanmıştır. Hazır OSM döşeme sunucusu kullanılmaz. Google Maps ve Apple Maps verisi alınmamıştır.

## Yazı tipleri

- Cormorant Garamond — Google Fonts resmi deposu: https://github.com/google/fonts/tree/main/ofl/cormorantgaramond
- Manrope — Google Fonts resmi deposu: https://github.com/google/fonts/tree/main/ofl/manrope
- İkisi de SIL Open Font License 1.1. Orijinal bildirimler `ios/assets/serif-OFL.txt` ve `ios/assets/sans-OFL.txt` içinde korunmuştur. Ticari yazılım içine gömülerek kullanılabilir; fontların tek başına satılmasına ilişkin sınırlama ve diğer lisans koşulları geçerlidir.

## Görseller

`ios/assets/istanbul-photos.png`, bu proje için yerleşik OpenAI image_gen aracıyla üretildi. İnternetten üçüncü taraf fotoğraf kopyalanmadı. Dört bölümlü görsel, arayüzde CSS ile ve iPhone’da yerel görüntü kırpmasıyla kullanılır.

Üretim istemi: “Four photorealistic contemporary Istanbul travel scenes in an equal 2×2 contact sheet: a white Bosphorus ferry at golden hour, a Galata street with the tower, Maiden’s Tower, Sultanahmet skyline. Warm natural light, no logos, readable signs, text or watermark.”

Görseller temsilidir; gerçek mekânların ve mimarinin birebir doğruluğu iddia edilmez. Yapay zekâ çıktılarında münhasır hak veya dünya genelinde kesin hukuki koruma iddia edilmez. Kullanım OpenAI hesabına uygulanabilir hizmet koşullarına tabidir.

## Simgeler ve metinler

Web SVG simgeleri ve rehber metinleri bu proje için hazırlandı. iOS sürümü platformun SF Symbols sistem simgelerini kullanır. İzinsiz alınmış ücretli ikon veya stok fotoğraf paketi bulunmaz.


## Gerçek mekân fotoğrafları — güncelleme

Mekân kartları, keşif seçkileri, harita kartı ve ayrıntıları artık Wikimedia Commons kaynaklı gerçek fotoğrafları kullanır. Önceki temsili atlas yalnızca açılış fotoğrafında kullanılır. Her fotoğrafın yazarı, kaynak bağlantısı, lisansı ve değişiklik bilgisi `PHOTO_CREDITS.md` ve `ios/assets/photo-credits.json` dosyalarında kayıtlıdır. Kartlarda, mekân ayrıntılarında ve web kaynaklar bölümünde atıflar gösterilir.


## Yeni görsel kimlik — İstanbul’un içine

Ana deneyim artık bu proje için OpenAI image_gen aracıyla oluşturulan `istanbul-scenes.png` (vapur, sokak, kıyı, park) ve `istanbul-places.png` (sekiz mekânın sanatsal yorumu) illüstrasyonlarını kullanır. Üretim istemleri: onaylanan görsel konsepte bağlı sıcak gün batımı, temiz geometrik mimari formlar, gerçek yapıların tanınabilir oranları, metinsiz sekiz İstanbul sahnesi. İlk atlas 2×2, mekân atlası 4×2 düzenindedir. Başka mekâna ait bir fotoğrafla eşleştirilmez. Çizimler belge niteliğinde değildir. Gerçek fotoğraflar, lisans ve atıflarıyla birlikte ayrıntılardaki ayrı fotoğraf görünümünde korunur.

Harita verisi ODbL lisansıyla aynı kalır. Harita üzerindeki Galata, Kız Kulesi, cami ve vapur çizimleri özgün SVG çizimleridir. Bağlantı çizgileri günlük durak sırasını gösterir; navigasyon veya yol tarifi değildir.
