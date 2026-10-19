# İstanbul — Şehre karış

Türkçe, iPhone için SwiftUI İstanbul keşif uygulaması. 60 mekân, ilçe ve kategori filtreleri, kaydedilenler, günlük durak listesi ve yerel harita içerir. Onaylanan görsel tarzında sekiz mekân çizimi ve dört atmosfer sahnesi bulunur.

## Çalıştırma

1. Bu depoyu macOS bilgisayarına indir.
2. Xcode ile `ios/IstanbulGuide.xcodeproj` dosyasını aç.
3. iOS 17 veya üzeri bir iPhone simülatörü seçip Run düğmesine bas.
4. Gerçek cihaz için Signing & Capabilities bölümünde kendi Team hesabını ve uygun Bundle Identifier değerini seç.

Kaynaklar ve görseller paket içindedir; API anahtarı veya paket bağımlılığı gerekmez. Çevrimdışı katalog, harita verisi ve cihazda tutulan plan/kayıtlar kullanılır. Dış kaynak bağlantıları internet gerektirir.

## Dosyalar

- `ios/IstanbulApp.swift`: SwiftUI arayüz ve uygulama davranışları.
- `ios/assets/places.json`: 60 mekânın açıklama, süre, etkinlik ve ilgili keşif kayıtları.
- `ios/assets/`: çizimler, mevcut gerçek fotoğraflar, yerel harita ve lisans dosyaları.
- `ios/artwork-manifest.json`: onaylanan çizimlerin üretim istemleri ve boyutları.
- `CONTENT_UPDATE.md`: içerik kapsamı, kaynaklar ve mevcut sınırlar.

## Mevcut durum

Bu bir geliştirme prototipidir. Yeni 52 mekânın kendine ait çizimi ve doğrulanmış harita konumu henüz eklenmemiştir; bu yerler isim ve kategori kartlarıyla gösterilir. Harita mevcut sekiz konum ve merkez İstanbul veri kesitiyle sınırlıdır. Süreler editoryal öneridir; güncel fiyat veya açık olma bilgisi sunulmaz. SwiftUI derlemesi Windows ortamında doğrulanamamıştır; Xcode üzerinde derleme ve cihaz testi gerekir. Bu pakette web sürümü bulunmaz.

## Haklar ve kaynaklar

Uygulama koduna açık kaynak lisansı eklenmemiştir. Depoya yüklemek üçüncü taraf varlıkların lisanslarını değiştirmez. Harita, fontlar ve fotoğrafların lisans/atıfları `THIRD_PARTY_NOTICES.md`, `PHOTO_CREDITS.md` ve assets içindeki kayıtlarda korunur. Çizimler OpenAI image_gen ile üretilmiş sanatsal yorumlardır.

## GitHub'a yükleme

ZIP'i açıp bu README ile aynı seviyedeki bütün dosya ve klasörleri deponun köküne yükle. `ios/assets` klasörünü dahil et; proje bu dosyaları kullanır. Gizli `.gitignore` dosyasını da ekle.
