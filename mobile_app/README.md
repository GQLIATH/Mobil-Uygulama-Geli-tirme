# Mobil Uygulama (Flutter - Kişi Yönetim Sistemi)

Mobil Programlama Dersi Vize Projesi kapsamında geliştirilen Flutter istemcisi.
Hem Django REST API sunucusu ile çevrimiçi (online) hem de sunucuya ulaşılamadığında yerel önbellek (`SharedPreferences`) üzerinden çevrimdışı (offline) olarak çalışır.

## Özellikler
- **Kişi Listesi (`GET /api/persons`):** Dairesel profil fotoğrafı (`GlowAvatar`), kalın Ad-Soyad ve Departman bilgisiyle kaydırılabilir `ListView`.
- **Kişi Detay Sayfası (`GET /api/persons/{id}`):** Büyük profil fotoğrafı, departman rozeti, doğum yeri/tarihi ve tıklanabilir **E-posta (`mailto:`)** ile **Telefon (`tel:`)** satırları (`url_launcher`).
- **Kişi Ekleme & Düzenleme (`POST` / `PUT`):** Cihaz galerisinden veya dosya gezgininden profil fotoğrafı seçme (`image_picker`), tarih seçici ve doğrulamalı form.
- **Kişi Silme (`DELETE /api/persons/{id}`):** Onay diyaloglu kalıcı silme işlemi.
- **Hibrit Offline Modu:** Sunucu kapalıysa 1.5 saniye içinde yerel veriye geçer; ekleme/düzenleme/silme işlemleri cihazda saklanır ve sunucu açıldığında otomatik eşitlenir.

## Çalıştırma Adımları

```bash
cd mobile_app
flutter pub get

# Chrome (Web) üzerinde çalıştırma:
flutter run -d chrome

# Android Emülatör veya Fiziksel Cihazda çalıştırma:
flutter run

# Kurulabilir APK derlemesi alma:
flutter build apk --release
```

Derlenen APK dosyası şu konumda oluşur:
`mobile_app/build/app/outputs/flutter-apk/app-release.apk`
