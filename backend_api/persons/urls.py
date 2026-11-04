from rest_framework.routers import DefaultRouter

from .views import PersonViewSet

# Router, ViewSet'ten /persons/ ve /persons/{id}/ adreslerini kendisi üretir.
#
# trailing_slash=False: ödevdeki adresler sonda '/' olmadan yazılmış
# (/api/persons ve /api/persons/{id}), onlarla birebir uyuşsun diye.
router = DefaultRouter(trailing_slash=False)
router.register("persons", PersonViewSet, basename="person")

urlpatterns = router.urls
