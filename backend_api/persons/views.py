from rest_framework import viewsets

from .models import Person
from .serializers import PersonSerializer


class PersonViewSet(viewsets.ModelViewSet):
    """Tek sınıf, 5 uç noktanın hepsini sağlar:
    GET list, GET detail, POST create, PUT update (ve PATCH), DELETE."""

    queryset = Person.objects.all()
    serializer_class = PersonSerializer
