# Istanbul — SwiftUI

Turistler için İstanbul ulaşım uygulaması prototipi. Bundan sonraki geliştirme yalnızca iOS kaynaklarında yapılır; eski tarayıcı önizlemesi güncellenmez.

## Güncel görsel tasarım

Onaylanan önizlemeye göre dört ekran ortak krem zemin, turkuaz vurgu, mercan butonlar ve serif başlıklarla güncellendi. Ana ekranda Galata/tramvay illüstrasyonu ve hedef seçimine bağlanan üç landmark kartı bulunur. Başlangıç ekranında Galata illüstrasyonu, hedef listesinde atlas küçük resimleri, rota ekranında yeni kart/harita düzeni kullanılır. Butonların basma animasyonu ve Reduce Motion desteği korunur. Açık tema sabittir.

Harita zemini gerçek Apple Maps'tir; temsili görselde üretilen çizilmiş sokak haritası uygulamaya statik arka plan olarak konmadı. Gerçek koordinat ve yönlendirme korunur. Görseldeki tüm ayrıntıların birebir eşleştiği iddia edilmez. Windows'ta iOS ekranı render edilmedi; son görsel kontrol Mac'te yapılmalıdır.

## Xcode'da çalıştırma

Mac, Xcode 16 veya üstü ve iOS 17 veya üstü gerekir. Bu paket kaynakları içerir; henüz `.xcodeproj` yoktur.

1. Xcode → New Project → iOS App. Proje adı `IstanbulHome`, Interface SwiftUI, Language Swift; minimum iOS 17.
2. Oluşan App dosyasını `IstanbulHomeApp.swift` ile değiştirin; tek bir `@main` olsun.
3. Diğer kök `.swift` dosyalarının hepsini uygulama hedefine ekleyin: HomeView, RouteCatalog, RouteOptionsView, PlaceCatalog, DestinationPickerView, LandmarkArtwork, StartingPoint, StartingPointServices, StartingPointPickerView. Eski `JourneyMapView.swift` gerekli değil.
4. Ayrıca `PilotNetwork.swift`, `PilotWalkingDirections.swift`, `PilotRoutePlanner.swift`, `PilotRouteResultsView.swift` dosyalarını uygulama hedefine ekleyin. `routes.json` ve `pilot-network.json` dosyalarını hedefe ve Copy Bundle Resources'a ekleyin.
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

**Compare routes artık gerçek başlangıç koordinatını kullanır.** Pilot bölge Beyoğlu–Kabataş–Karaköy–Eminönü–Sultanahmet–Beyazıt; hatlar T1 ve F1'dir. Hedefler Galata, Taksim, Eminönü, Kapalıçarşı, Sultanahmet, Ayasofya ve Sultanahmet Camii'dir. Yakın durak adayları koordinattan seçilir; erişim, aktarma ve hedef yürüyüşleri Apple MKDirections ile alınır. Ağ başarısızsa düz çizgi yürüyüş uydurulmaz. Başlangıç değişince durak adayları yeniden hesaplanır. Aynı başlangıç ve hedef 25 m mesafe kontrolünden anlaşılır.

Kullanıcı İstanbul saatinde kalkış ve her yürüyüş ayağı için 600/1200/2000 m sınır seçer. Kabataş F1–T1 aktarması iki yönde desteklenir, yürüyüşü en fazla 350 m'dir. En yakın üç giriş/çıkıştan en fazla altı raylı aday denenir; bütün olası güzergâhlar taranmaz. Sonuçlar az biniş, sonra az yürüyüş ile sıralanır; en ucuz/en hızlı garantisi yoktur. Durak merkezleri giriş kapısı değildir.

Güncel kesin kalkışlar, bekleme süreleri, ücretler ve toplam yolculuk süresi henüz yoktur. Resmî normal 06:00–00:00 penceresi kontrol edilir; son 30 dakika uygulamanın ihtiyat kuralıyla dışlanır. Bu, son sefer saati değildir ve aktarma yakalama garantisi vermez. T1 sürüş süresi bilinmediğinden sonraki biniş saati ancak alt sınırdır. İleriki tarihli seçimlerde normal pencere uygulanır, o günün gerçek servis durumu doğrulanmaz. Ayrıntılar: `TRANSIT_DATA_AUDIT.md`.

## Diğer mevcut özellikler

Turkuaz, krem ve mercan tasarım; yer seçimi için MapKit ve 10 landmark noktası; dokunma animasyonları ve desteklenen iPhone'da haptikler. Haritadaki landmark illüstrasyonları projeye özel ImageGen üretimidir; özgün panoya göre hazırlanmış altı resim tek transparan atlas içindedir. Küçük vapurlar dekor, gerçek araç konumu değildir. Haritadaki noktalar yaklaşık landmark/semte ait referanslardır; erişilebilir girişleri göstermez.

Eski altı hazır yolculuk `routes.json` içinde arşiv olarak durur; yeni Compare routes hesabında kullanılmaz. Kadıköy, Üsküdar ve havalimanı yeni pilot kapsamı dışındadır. Raylı hat çizgileri arşiv geometrisiyle kesikli, Apple yürüyüş güzergâhları düz çizgi stiliyle gösterilir.

## Doğrulama ve cihaz kontrolü

Windows'ta hazırlanan kaynaklar henüz Xcode'da derlenmedi. GPS ve MapKit ağ hizmetleri burada çalıştırılamaz; derleme, gerçek iPhone ve simülatör testleri Mac'te yapılmalıdır.

`Tests/StartingPointTests.swift` ve `Tests/PilotRoutingTests.swift` XCTest testleri içerir; burada çalıştırılmamıştır. Xcode'da uygulamayı host olarak kullanan Unit Test target ekleyip yalnızca test hedefine ekleyin. Uygulama modülü farklıysa `@testable import IstanbulHome` satırını uyarlayın. Rota testleri yapay yürüyüş sağlayıcısı kullanır; gerçek Apple servis entegrasyonunu doğrulamaz.

Mac'te ayrıca şu akışları kontrol edin: izin ver/reddet; konum servisleri kapalı; yaklaşık konum; simülatörde konum yok; adres aramasında internet yok; hızlı sorgu değişimi; GPS beklerken map pin seçimi; geri dönünce eski seçimin korunması; yeni başlangıçla mevcut varışın korunması; VoiceOver ve büyük yazı; klavye açıkken adres sonuçlarını seçebilme. Web sürümü ve eski JavaScript testleri bu iOS özelliğini doğrulamaz.
