# Istanbul — SwiftUI

Turistler için İstanbul ulaşım uygulaması prototipi. Bundan sonraki geliştirme yalnızca iOS kaynaklarında yapılır; eski tarayıcı önizlemesi güncellenmez.

## Xcode'da çalıştırma

Mac, Xcode 16 veya üstü ve iOS 17 veya üstü gerekir. Bu paket kaynakları içerir; henüz `.xcodeproj` yoktur.

1. Xcode → New Project → iOS App. Proje adı `IstanbulHome`, Interface SwiftUI, Language Swift; minimum iOS 17.
2. Oluşan App dosyasını `IstanbulHomeApp.swift` ile değiştirin; tek bir `@main` olsun.
3. Diğer kök `.swift` dosyalarının hepsini uygulama hedefine ekleyin: HomeView, RouteCatalog, RouteOptionsView, PlaceCatalog, DestinationPickerView, LandmarkArtwork, StartingPoint, StartingPointServices, StartingPointPickerView. Eski `JourneyMapView.swift` gerekli değil.
4. `routes.json` dosyasını hedefe ve Copy Bundle Resources'a ekleyin.
5. Asset kataloğuna `BeyogluHero` ve `LandmarkAtlas` görsel setlerini ekleyin.
6. **Target → Info → Custom iOS Target Properties** altında `Privacy - Location When In Use Usage Description` (`NSLocationWhenInUseUsageDescription`) ekleyin. Değeri: `Your location is used only when you tap Use my location to choose a journey starting point.`
7. `LocationPrivacy.plist` yalnızca 6. adımdaki anahtarın örneğidir. Bundle resource olarak eklemeyin; uygulamanın üretilen Info.plist'ine bu anahtarın birleşmesi gerekir. Anahtar eksikse uygulama izin istemek yerine kurulum hatası gösterir.
8. iPhone simülatörü seçip Run'a basın. GPS denemesi için Simulator → Features → Location → Custom Location'dan bir koordinat girin; fiziksel iPhone'da gerçek konum kullanılabilir.

## Serbest başlangıç seçimi — özellik 1

Ana ekrandaki **From** alanı yeni Starting point ekranını açar:

- **Use my location:** Kullanıcı dokununca yalnızca kullanım sırasındaki konum izni istenir. Tek seferlik konum alınır, sürekli veya arka planda takip yapılmaz. Yaklaşık konum da kabul edilir; doğruluk kartta yazılır.
- **Adres arama:** Sokak, otel veya adres yazılır; Apple MKLocalSearch sonuçlarından seçim yapılır. İstanbul'a öncelik verilir, sonuçların koordinatları kullanılır. İnternet gerekir. Hızlı yazılan sorgular iptal/debounce edilir; eski sonuçlar yeni sorguyu ezmez.
- **Haritaya dokunma:** Haritada herhangi bir geçerli koordinata pin bırakılır. Kesin adres uydurulmaz; kartta Pinned location ve koordinat gösterilir. VoiceOver için haritayı kaydırıp Use map centre düğmesi de kullanılabilir.
- **Use this starting point:** Seçim ancak bu düğmeyle onaylanır. Geri gitmek eski başlangıç/varışı korur. Yeni başlangıç seçmek varış seçimini silmez. Seçim uygulama belleğinde tutulur; diske kaydedilmez.

İzin reddi/kısıtlaması, konum zaman aşımı ve ağ hatası için açıklamalar vardır. Manuel seçim yapılınca bekleyen GPS isteği durdurulur. Ekrandan çıkınca arama ve konum isteği iptal edilir. GPS kullanılmadan adres/harita seçimi çalışır.

**Bu aşamada serbest koordinattan toplu taşıma rotası hesaplanmaz.** Compare routes, GPS/adres/pin seçimi için bunu açıklar. Önceden eklenmiş altı yolculuk yalnızca katalogdan seçilen landmark başlangıçlarıyla çalışır. Arama sonucunun adı Galata Tower olsa bile rastgele koordinat eski rotaya bağlanmaz. Aynı başlangıç ve hedef, adından değil 25 m mesafe kontrolünden anlaşılır.

## Diğer mevcut özellikler

Turkuaz, krem ve mercan tasarım; yer seçimi için MapKit ve 10 landmark noktası; dokunma animasyonları ve desteklenen iPhone'da haptikler. Haritadaki landmark illüstrasyonları projeye özel ImageGen üretimidir; özgün panoya göre hazırlanmış altı resim tek transparan atlas içindedir. Küçük vapurlar dekor, gerçek araç konumu değildir. Haritadaki noktalar yaklaşık landmark/semte ait referanslardır; erişilebilir girişleri göstermez.

Altı hazır yolculuk: Galata → Sultanahmet; Taksim → Sultanahmet; Sultanahmet → Kapalıçarşı; Eminönü → Kadıköy; Eminönü → Üsküdar; Sabiha Gökçen → Kadıköy. Galata ve Kapalıçarşı yolculuklarında yürüyüş alternatifi bulunur. Ücret/süre hesaplama, en ucuz/en hızlı sıralaması ve canlı seferler henüz yoktur. Ayasofya ve Sultanahmet Camii haritada seçilebilir; bu hedeflerin rota hesabı henüz eklenmedi. Hat kaynakları `routes.json` içindedir.

## Doğrulama ve cihaz kontrolü

Windows'ta hazırlanan kaynaklar henüz Xcode'da derlenmedi. GPS ve MapKit ağ hizmetleri burada çalıştırılamaz; derleme, gerçek iPhone ve simülatör testleri Mac'te yapılmalıdır.

`Tests/StartingPointTests.swift` model sınır durumları için XCTest testleri içerir; burada çalıştırılmamıştır. Xcode'da Unit Test target ekleyip yalnızca test hedefine ekleyin. Uygulama modülü farklıysa `@testable import IstanbulHome` satırını uyarlayın.

Mac'te ayrıca şu akışları kontrol edin: izin ver/reddet; konum servisleri kapalı; yaklaşık konum; simülatörde konum yok; adres aramasında internet yok; hızlı sorgu değişimi; GPS beklerken map pin seçimi; geri dönünce eski seçimin korunması; yeni başlangıçla mevcut varışın korunması; VoiceOver ve büyük yazı; klavye açıkken adres sonuçlarını seçebilme. Web sürümü ve eski JavaScript testleri bu iOS özelliğini doğrulamaz.
