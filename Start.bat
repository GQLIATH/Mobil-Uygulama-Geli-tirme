@echo off
chcp 65001 >nul
set "ROOT=%~dp0"
set "PY=%ROOT%backend_api\.venv\Scripts\python.exe"

rem 0) Sanal ortam yoksa (ör. proje başka bilgisayara kopyalandıysa) oluştur ve paketleri kur
if not exist "%PY%" (
    echo [Kurulum] Python sanal ortami bulunamadi, olusturuluyor...
    python -m venv "%ROOT%backend_api\.venv"
    "%PY%" -m pip install -r "%ROOT%backend_api\requirements.txt"
    "%PY%" "%ROOT%backend_api\manage.py" migrate
    "%PY%" "%ROOT%backend_api\manage.py" seed
)

rem 1) Backend'i yeni bir pencerede başlat.
rem    activate.bat yerine sanal ortamın python.exe'si doğrudan çağrılıyor;
rem    böylece klasör taşınsa/kopyalansa bile doğru Python (Django kurulu olan) kullanılır.
start "Backend" cmd /k "cd /d "%ROOT%backend_api" && "%PY%" manage.py runserver 0.0.0.0:8000"

rem 2) Backend'in açılması için 5 saniye bekle
timeout /t 5 /nobreak >nul

rem 3) Flutter'ı Chrome'da yeni bir pencerede başlat
start "Flutter" cmd /k "cd /d "%ROOT%mobile_app" && flutter run -d chrome"
