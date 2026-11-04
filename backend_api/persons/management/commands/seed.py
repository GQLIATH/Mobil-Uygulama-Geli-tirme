from datetime import date

from django.core.management.base import BaseCommand

from persons.models import Person

ORNEKLER = [
    (
        "Burak Karahan",
        "Yazılım Geliştirme Departmanı",
        "İstanbul",
        date(1993, 5, 14),
        "burak.karahan@teknoloji.com",
        "+905324108520",
        33,
    ),
    (
        "Selin Özdemir",
        "Siber Güvenlik Departmanı",
        "Ankara",
        date(1995, 8, 22),
        "selin.ozdemir@teknoloji.com",
        "+905443189640",
        47,
    ),
    (
        "Emre Çelik",
        "Veri Bilimi ve Yapay Zeka Departmanı",
        "İzmir",
        date(1990, 11, 9),
        "emre.celik@teknoloji.com",
        "+905056721930",
        60,
    ),
    (
        "Deniz Aydın",
        "Ürün Yönetimi Departmanı",
        "Antalya",
        date(1997, 2, 19),
        "deniz.aydin@teknoloji.com",
        "+905368914075",
        32,
    ),
    (
        "Kaan Yıldırım",
        "Bulut Altyapı ve Sistem Departmanı",
        "Bursa",
        date(1992, 7, 4),
        "kaan.yildirim@teknoloji.com",
        "+905337452810",
        53,
    ),
    (
        "Elif Şahin",
        "İnsan Kaynakları Departmanı",
        "Eskişehir",
        date(1996, 10, 27),
        "elif.sahin@teknoloji.com",
        "+905429036184",
        44,
    ),
]


class Command(BaseCommand):
    help = "Örnek kişi verisi ekler (tablo boşsa)."

    def handle(self, *args, **options):
        if Person.objects.exists():
            self.stdout.write("Tabloda zaten veri var, atlandı.")
            return
        for ad, dep, yer, tarih, mail, tel, img in ORNEKLER:
            Person.objects.create(
                full_name=ad,
                department=dep,
                birth_place=yer,
                birth_date=tarih,
                email=mail,
                phone=tel,
                photo_url=f"https://i.pravatar.cc/300?img={img}",
            )
        self.stdout.write(self.style.SUCCESS(f"{len(ORNEKLER)} kişi eklendi."))
