# Backend API (Django REST Framework)

Kişi Yönetim Sistemi için REST servisi. SQLite kullanır, ayrı veritabanı kurulumu gerekmez.

## Gereksinimler
- Python 3.10 veya üstü

## Kurulum (Windows PowerShell / macOS / Linux)

```bash
cd backend_api

# 1) Sanal ortam oluştur ve aç
python -m venv .venv
# Windows:   .\.venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate

# 2) Paketleri kur
pip install -r requirements.txt

# 3) Veritabanı tablolarını oluştur
python manage.py makemigrations persons
python manage.py migrate

# 4) Örnek verileri ekle (isteğe bağlı)
python manage.py seed

# 5) Sunucuyu başlat (0.0.0.0: emülatör ve telefon erişebilsin)
python manage.py runserver 0.0.0.0:8000
```

Sunucu şu adreste çalışır: http://127.0.0.1:8000/api/persons

## Uç Noktalar

| Metot | Adres | Açıklama |
|---|---|---|
| GET | /api/persons | Tüm kişileri listeler |
| GET | /api/persons/{id} | Tek kişinin detayı |
| POST | /api/persons | Yeni kişi oluşturur |
| PUT | /api/persons/{id} | Kişiyi günceller |
| DELETE | /api/persons/{id} | Kişiyi siler |

## Örnek JSON

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
