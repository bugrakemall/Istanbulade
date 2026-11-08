# Istanbul Explorer

Bu paket Figma’daki ilk dört ekranı içerir: karşılama, ana ekran, kategoriler ve yer listesi. Categories → Historical Places yoluyla Ayasofya, Topkapı Sarayı, Sultanahmet Camii, Galata Kulesi ve Kız Kulesi listelenir. Yer seçince ortak fotoğraf önizlemesi açılır. Tam yer detayı, sesli rehber, galeri, favoriler ve hakkında ekranları henüz eklenmedi.

Mac’te `IstanbulExplorer.xcodeproj` dosyasını aç, iPhone simülatörü seç ve Run’a bas. Minimum iOS 17.

- `IstanbulExplorerApp.swift`: Karşılama ve ana ekran arasında geçiş.
- `WelcomeView.swift`: Başlık, oynatma kontrolü ve giriş alanı.
- `SunsetScene.swift`: Açılışta otomatik başlayan, 12 saniyelik hafif kamera hareketi. Ortadaki düğmeyle duraklatılır; Hareketi Azalt açıksa görsel sabit kalır. Video dosyası yoktur.
- `SlideToExplore.swift`: Sağa sürüklenen giriş düğmesi.
- `ExplorerHomeView.swift`: Ana ekran, arama ve popüler yerler.
- `ExplorerCategoryCards.swift`: Ana ekrandaki üç renkli kategori kısayolu.
- `ExplorerMainView.swift`: Home ve Categories sekmeleri, kategori listesine geçiş.
- `CategoriesView.swift`: Büyük görselli üç kategori kartı.
- `CategoryPlacesView.swift`: Seçili kategorinin görselli ve açıklamalı yer listesi.
- `PlacePreviewView.swift`: Ana ekran ile yer listesinin ortak fotoğraf önizlemesi.
- `ExplorerPlace.swift`: Kayıtlı örnek yerler ve kategoriler.
- `ExplorerArtwork.swift`: Fotoğraf koleksiyonundan doğru kareyi gösterir.

Proje bağlantıları Windows’ta kontrol edildi; Xcode derlemesi ve simülatör görünümü henüz doğrulanmadı.
