from rest_framework import serializers

from .models import Person


class PersonSerializer(serializers.ModelSerializer):
    """Model <-> JSON çevirici.
    Python tarafında alan adları snake_case (full_name), ama ödevin JSON
    şeması camelCase (fullName) istiyor. 'source' ile bu eşlemeyi yapıyoruz."""

    fullName = serializers.CharField(source="full_name")
    photoUrl = serializers.CharField(source="photo_url", required=False, allow_blank=True)
    birthPlace = serializers.CharField(source="birth_place", required=False, allow_blank=True)
    birthDate = serializers.DateField(source="birth_date", required=False, allow_null=True)

    class Meta:
        model = Person
        fields = [
            "id",
            "fullName",
            "department",
            "photoUrl",
            "birthPlace",
            "birthDate",
            "email",
            "phone",
        ]
