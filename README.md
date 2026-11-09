# Istanbul Explorer

Bu paket Figma’daki ilk altı ekranı içerir: karşılama, ana ekran, kategoriler, yer listesi, yer detayı ve galeri. **Categories → Historical Places → Hagia Sophia** ile detay ekranına ulaşılır. Ana ekrandaki kartlar da detayı açar.

Kalp, yeri cihazda favori olarak kaydeder. Favoriler sekmesinin listesi daha sonra eklenecek. **View Gallery**, iki sütunda on görsellik İstanbul galerisini açar; görsele dokununca büyür. **Play Audio Guide** düğmesi görünür ama şimdilik pasiftir; ses dosyaları pakete dahil değildir.

Rehber metinleri için kaynaklar: [UNESCO — İstanbul’un Tarihî Alanları](https://whc.unesco.org/en/list/356), [Go Türkiye — Sultanahmet Camii](https://goturkiye.com/istanbul/blue-mosque), [Kız Kulesi](https://goturkiye.com/istanbul/maidens-tower), [Ortaköy](https://goturkiye.com/istanbul/ortakoy) ve [İstanbul gezi rehberi](https://goturkiye.com/branding/press-releases/live-an-unforgettable-48-hours-in-istanbul).

Mac’te `IstanbulExplorer.xcodeproj` dosyasını aç, iPhone simülatörü seç ve Run’a bas. Minimum iOS 17.

Girişteki kaydırma için [SlideButton 1.3.0](https://github.com/no-comment/SlideButton/tree/v1.3.0) kullanılır (MIT). Paket `Vendor/SlideButton` klasöründe hazırdır ve Xcode projesine yerel bağımlılık olarak bağlıdır. ZIP’i tamamen çıkar; `Vendor` klasörü `IstanbulExplorer.xcodeproj` ile yan yana kalmalı. Paketi GitHub’dan tekrar indirmeye veya Xcode’a elle eklemeye gerek yok.

- `IstanbulExplorerApp.swift`: Karşılama ve ana ekran arasında geçiş.
- `WelcomeView.swift`: Başlık, oynatma kontrolü ve giriş alanı.
- `SunsetScene.swift`: Açılışta otomatik başlayan, 12 saniyelik hafif kamera hareketi. Ortadaki düğmeyle duraklatılır; Hareketi Azalt açıksa görsel sabit kalır. Video dosyası yoktur.
- `SlideToExplore.swift`: Hazır SlideButton bileşenine sarı rengi, yazıyı ve ana ekrana geçiş işlemini verir.
- `ExplorerHomeView.swift`: Ana ekran, arama ve popüler yerler.
- `ExplorerCategoryCards.swift`: Ana ekrandaki üç renkli kategori kısayolu.
- `ExplorerMainView.swift`: SwiftUI TabView ve kategori listesine geçiş. Favorites ve About şimdilik boş durum gösterir.
- `CategoriesView.swift`: Büyük görselli üç kategori kartı.
- `CategoryPlacesView.swift`: Seçili kategorinin görselli ve açıklamalı yer listesi.
- `PlaceDetailView.swift`: Yer bilgisi, favori kalbi ve galeri düğmesi.
- `AudioGuideView.swift`: Sesli rehber için pasif SwiftUI düğmesi.
- `GalleryView.swift`: İki sütunlu İstanbul galerisi ve büyük görsel önizlemesi.
- `ExplorerPlace.swift`: Kayıtlı örnek yerler ve kategoriler.
- `ExplorerArtwork.swift`: Fotoğraf koleksiyonundan doğru kareyi gösterir.

Proje bağlantıları Windows’ta kontrol edildi; Xcode derlemesi ve simülatör görünümü henüz doğrulanmadı.
