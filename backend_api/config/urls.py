from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    # /api/ ile başlayan her şey persons uygulamasına gider
    path("api/", include("persons.urls")),
]
