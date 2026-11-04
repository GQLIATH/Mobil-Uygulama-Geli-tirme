from django.db import models


class Person(models.Model):
    """Veritabanındaki 'persons_person' tablosunun karşılığı.
    Her alan tabloda bir sütun olur. 'id' alanını Django kendisi ekler."""

    full_name = models.CharField(max_length=120)
    department = models.CharField(max_length=120)
    photo_url = models.TextField(blank=True)
    birth_place = models.CharField(max_length=80, blank=True)
    birth_date = models.DateField(null=True, blank=True)
    email = models.EmailField(blank=True)
    phone = models.CharField(max_length=30, blank=True)

    class Meta:
        ordering = ["id"]

    def __str__(self):
        return self.full_name
