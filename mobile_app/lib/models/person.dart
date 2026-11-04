/// Sunucudan gelen JSON'un Dart karşılığı.
class Person {
  final int? id; // yeni kayıtta henüz yok (null), sunucu verir
  final String fullName;
  final String department;
  final String photoUrl; // internet adresi VEYA cihazdan seçilen "data:image/..." (Base64)
  final String birthPlace;
  final String birthDate; // "1994-04-12" biçiminde metin
  final String email;
  final String phone;

  const Person({
    this.id,
    required this.fullName,
    required this.department,
    this.photoUrl = '',
    this.birthPlace = '',
    this.birthDate = '',
    this.email = '',
    this.phone = '',
  });

  /// JSON (Map) -> Person nesnesi. Sunucudan gelen veriyi okurken kullanılır.
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int?,
      fullName: json['fullName'] ?? '',
      department: json['department'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      birthPlace: json['birthPlace'] ?? '',
      birthDate: json['birthDate'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  /// Person nesnesi -> JSON (Map). Sunucuya POST/PUT gönderirken kullanılır.
  /// 'id' gönderilmez, çünkü adreste zaten var (veya sunucu üretir).
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'department': department,
      'photoUrl': photoUrl,
      'birthPlace': birthPlace,
      // Boş tarih için null gönderiyoruz, yoksa sunucu "geçersiz tarih" der.
      'birthDate': birthDate.isEmpty ? null : birthDate,
      'email': email,
      'phone': phone,
    };
  }

  /// Cihazda (yerel önbellekte) saklarken kullanılır; 'id' de dahildir.
  Map<String, dynamic> toLocalJson() => {'id': id, ...toJson()};

  /// Aynı kişinin farklı id'li kopyası (offline eklenen kayda geçici id vermek için).
  Person copyWith({int? id}) {
    return Person(
      id: id ?? this.id,
      fullName: fullName,
      department: department,
      photoUrl: photoUrl,
      birthPlace: birthPlace,
      birthDate: birthDate,
      email: email,
      phone: phone,
    );
  }
}
