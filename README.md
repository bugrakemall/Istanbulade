# Istanbul Explorer

SwiftUI ile hazırlanmış, Figma'daki sekiz ekranı içeren iOS ders projesi:

1. Hareketli manzaralı karşılama ve sağa kaydırarak giriş.
2. Ana ekran, yer arama ve popüler yerler.
3. Kategoriler.
4. Kategoriye göre yer listesi.
5. Yer detayı ve favorilere ekleme.
6. Galeri ve büyük görsel önizlemesi.
7. Kalıcı favoriler; detaya geçiş ve kaydırarak silme.
8. Hakkında ve üç kişilik ekip bilgisi.

## Çalıştırma

Mac'te bu klasördeki `IstanbulExplorer.xcodeproj` dosyasını Xcode ile aç. IstanbulExplorer scheme'ini ve bir iPhone simülatörünü seçip Run'a bas. Minimum iOS 17. Fiziksel iPhone için Signing & Capabilities bölümünden kendi Team hesabını seç; gerekirse Bundle Identifier'ı benzersiz yap.

Harici paket kurulumu gerekmez. Girişte SwiftUI Slider kullanılır. Eski projedeki SlideButton hatası devam ederse bu sürümü ayrı klasöre indirip onun xcodeproj dosyasını aç; eski pencereyi kapat.

## Kod düzeni

Her ekran ayrı Swift dosyasındadır. ExplorerMainView, dört sekmeyi native TabView ve NavigationStack ile yönetir. ExplorerPlace yer verilerini, ExplorerArtwork görsel koleksiyonlarını içerir. FavoritesView ve PlaceDetailView aynı AppStorage anahtarını kullanır; favoriler cihazda saklanır. Uzun olmayan kodlarda gerekli Türkçe yorumlar bulunur.

## Mevcut sınırlar

Açılış bir fotoğraf üzerindeki hafif kamera animasyonudur, video dosyası değildir. Önceki talebe göre Play Audio Guide görünür ama pasiftir; ses dosyası yoktur. Galeride on farklı yapay zekâ görseli bulunur; gerçek fotoğraf olarak sunulmaz. Ekip üyelerinin isimleri henüz girilmedi. Reklam, rota ve harici harita eklenmedi.

Dersin 15 görsel, bir gerçek video ve bir ses dosyası şartları bu sürümde tamamen karşılanmaz. Bu medya dosyaları teslimden önce ayrıca tamamlanmalıdır.

Proje dosyasındaki kaynak bağlantıları ve görsel dosyaları Windows'ta kontrol edildi. Bu ortamda Xcode/iOS simülatörü olmadığından derleme ve cihaz testi yapılmadı.

Rehber metinleri için kaynaklar: [UNESCO](https://whc.unesco.org/en/list/356), [Go Türkiye — Sultanahmet Camii](https://goturkiye.com/istanbul/blue-mosque), [Kız Kulesi](https://goturkiye.com/istanbul/maidens-tower), [Ortaköy](https://goturkiye.com/istanbul/ortakoy).
