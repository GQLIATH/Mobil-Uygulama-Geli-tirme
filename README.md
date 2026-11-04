# Kişi Yönetim Sistemi (Client-Server REST Mimarisi)

Mobil Programlama Dersi Vize Sınavı Proje Çalışması.

## 📁 Klasör Yapısı

- **`/backend_api`**: Django REST Framework (DRF / Python) ile geliştirilmiş REST API sunucusu.
- **`/mobile_app`**: Flutter (Dart) ile geliştirilmiş mobil/web istemci uygulaması.
- **`KisiYonetimSistemi-release.apk`**: Android cihazlara doğrudan kurulabilir derlenmiş test paketi (APK).

---

## 🚀 1. API Servisinin Yerelde Kurulumu (`backend_api`)

### Gereksinimler
- Python 3.10 veya üstü (Ayrı bir veritabanı kurulumu gerekmez, yerleşik SQLite kullanılır).

### Adım Adım Kurulum (Windows PowerShell / CMD / macOS / Linux)

```bash
# 1) Backend klasörüne gidin
cd backend_api

# 2) Sanal ortam (virtual environment) oluşturun ve etkinleştirin
python -m venv .venv

# Windows PowerShell için:
.\.venv\Scripts\Activate.ps1
# Windows CMD için:
.\.venv\Scripts\activate.bat
# macOS / Linux için:
source .venv/bin/activate

# 3) Gerekli Python paketlerini yükleyin
pip install -r requirements.txt

# 4) Veritabanı tablolarını oluşturun
python manage.py makemigrations persons
python manage.py migrate

# 5) Başlangıç örnek kişi verilerini veritabanına ekleyin
python manage.py seed

# 6) API sunucusunu başlatın (0.0.0.0: emülatör ve yerel ağ erişimi için)
python manage.py runserver 0.0.0.0:8000
```

Sunucu çalıştığında API adresi: **`http://127.0.0.1:8000/api/persons`**

---

## 📡 2. REST API Uç Noktaları ve JSON Şeması

| HTTP Metodu | Uç Nokta | Açıklama |
| :--- | :--- | :--- |
| `GET` | `/api/persons` | Tüm kişileri dizi (`array`) formatında listeler. |
| `GET` | `/api/persons/{id}` | Belirtilen ID'ye sahip kişinin tüm detaylarını döner. |
| `POST` | `/api/persons` | Yeni kişi kaydı oluşturur (Form body JSON). |
| `PUT` | `/api/persons/{id}` | Kişinin iletişim ve unvan bilgilerini günceller. |
| `DELETE` | `/api/persons/{id}` | İlgili kaydı veritabanından kalıcı olarak siler. |

### Örnek Kişi JSON Şeması (Payload)
```json
{
  "id": 1,
  "fullName": "Burak Karahan",
  "department": "Yazılım Geliştirme Departmanı",
  "photoUrl": "https://i.pravatar.cc/300?img=33",
  "birthPlace": "İstanbul",
  "birthDate": "1993-05-14",
  "email": "burak.karahan@teknoloji.com",
  "phone": "+905324108520"
}
```

---

## 📱 3. Mobil Uygulamanın Çalıştırılması (`mobile_app`)

```bash
# 1) Mobil uygulama klasörüne gidin
cd mobile_app

# 2) Paketleri indirin
flutter pub get

# 3) Uygulamayı çalıştırın (Chrome veya açık olan Android Emülatör)
flutter run -d chrome
# veya Android cihaz/emülatör için:
flutter run
```

> **Not (Hibrit Offline Mod):** Sunucu kapalı olsa bile mobil uygulama 1.5 saniye içinde otomatik olarak yerel önbellek (`SharedPreferences`) moduna geçer ve tüm ekleme, fotoğraf yükleme, düzenleme ve silme işlemlerini çevrimdışı olarak çalıştırır.
