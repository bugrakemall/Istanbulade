# İstanbul pilot ulaşım verisi — 17 Ekim 2026

## Karar

Yerel T1/F1 hat grafiği + Apple MapKit yürüyüş servisi kullanılıyor. Sabit başlangıç/hedef eşleştirmesi yerine koordinattan yakın durak adayları çıkarılıyor. Bu pilot güncel tarifeli yolculuk planlayıcısı veya ücret optimizasyonu değildir.

## Kaynak denetimi

- [İBB toplu ulaşım GTFS metaverisi](https://data.ibb.gov.tr/api/3/action/package_show?id=public-transport-gtfs-data): HTTP 200 ile alındı. Paket açıklaması Metro İstanbul verisinin son güncellemesini 09.07.2020 olarak belirtiyor ve güncellenmeyeceğini söylüyor. İndirilen calendar.txt içindeki en ileri bitiş 2024-12-31. Portal metaverisinin daha yeni tarihi tarifeyi güncel yapmıyor. Eski stop_times/frequencies güncel sefer olarak kullanılmadı.
- [İETT GTFS metaverisi](https://data.ibb.gov.tr/api/3/action/package_show?id=iett-gtfs-verisi): erişilebilir, kaynakların güncellemesi 2026-03-17. Otobüs verisi; T1/F1 için güncel raylı tarife yerine kullanılmadı. Bu pilotta otobüs yok.
- [Metro İstanbul T1](https://www.metro.istanbul/Hatlarimiz/HatDetay?hat=T1): Kabataş, Fındıklı, Tophane, Karaköy, Eminönü, Sirkeci, Gülhane, Sultanahmet, Çemberlitaş, Beyazıt sırası ve normal 06:00–00:00 saatleri karşılaştırıldı. İleri yön Bağcılar, geri yön Kabataş. Tüm hat için yayımlanan süre alt kesimlere orantılanmadı.
- [Metro İstanbul F1](https://www.metro.istanbul/Hatlarimiz/HatDetay?hat=F1): Taksim–Kabataş, normal 06:00–00:00, 150 saniye tam hat süresi ve Kabataş T1 aktarması kontrol edildi. İki yönde bağlantı var.
- [Apple MKDirections](https://developer.apple.com/documentation/mapkit/mkdirections): yürüyüş mesafesi, tahmini yürüyüş süresi, adımlar ve geometri çalışma anında istenir. [Transit türü](https://developer.apple.com/documentation/mapkit/mkdirectionstransporttype/transit) tam rota geometrisi sağlamadığından raylı grafiğin yerine kullanılmadı. İstanbul'daki gerçek yanıtlar Mac/iPhone üzerinde henüz denenmedi.

## pilot-network.json

İBB arşivinden 10 T1, 2 F1 durak merkezi ve hat geometrisi seçildi. Hat sırası güncel operatör sayfalarıyla karşılaştırıldı; koordinatlar/girişler sahada yeniden ölçülmedi. Kabataş tek tanımlı aktarmadır; yakın görünen başka duraklara otomatik aktarma eklenmez. Yürüyüş bağlantısı ancak Apple gerçek yol döndürürse kabul edilir. Apple verisi geçici bellekte tutulur, diske yazılmaz ve Apple haritasında gösterilir.

Kapsam: 41.000–41.045 kuzey, 28.958–29.003 doğu; yalnızca belirtilen turistik hedefler. Adaylar en yakın üç giriş/çıkıştan türetilir, altı raylı seçenekle sınırlıdır. Tam ağ araması değildir. Deniz geçişinde kuş uçuşu mesafe sadece aday elemek içindir; gerçek yaya güzergâhı yerine kullanılmaz.

Kesin kalkış/son tren, bekleme, güncel kesinti, ücret, İstanbulkart/aktarma indirimi ve toplam süre bilinmiyor. Normal hizmet penceresinin son 30 dakikasının dışlanması uygulama tercihidir. Kontrol edilen saat en erken biniş alt sınırıdır; bilinmeyen bekleme/T1 süresi nedeniyle aktarmanın yetişeceği iddia edilmez. Bu bilgiler doğrulanmadan en ucuz rota iddiası eklenmemeli.

## Lisans ve doğrulama sınırı

[İBB veri lisansı](https://data.ibb.gov.tr/license) atıf koşuluyla ticari ve ticari olmayan kullanıma izin veriyor. Paket ve sonuç ekranı kaynak/lisans bağlantısı ile şu atfı içerir: “Atıf 4.0 Uluslararası (CC BY 4.0) kapsamında lisanslanan kamu sektörü bilgilerini içerir.” İBB onayı veya ortaklığı iddia edilmez. Bu izin Apple servis sözleşmesinin yerine geçmez.

Windows'ta veri tutarlılığı ve kaynak/paket kontrolleri yapıldı. Swift derlemesi, XCTest ve gerçek MapKit yürüyüş yanıtları henüz çalıştırılmadı. Mac'te farklı başlangıçlar, ters yön, F1–T1 aktarması, gece, ağ hatası ve yürüyüş sınırı denenmelidir.
