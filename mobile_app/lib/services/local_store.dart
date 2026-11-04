import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/person.dart';

/// Cihazın kendi hafızasında (SharedPreferences) veri saklayan sınıf.
/// - Kişi listesinin son hali (sunucuya ulaşılamazsa buradan gösterilir)
/// - Offline iken yapılan ve sunucuya henüz gönderilmemiş işlemler (kuyruk)
class LocalStore {
  static const _personsKey = 'persons_cache_v2';
  static const _opsKey = 'pending_ops_v2';

  /// Uygulama telefona veya bilgisayara ilk kez kurulup çevrimdışı açıldığında
  /// liste boş kalmasın diye sunucudaki seed.py ile aynı başlangıç verileri.
  static const List<Person> _initialPersons = [
    Person(
      id: 1,
      fullName: 'Burak Karahan',
      department: 'Yazılım Geliştirme Departmanı',
      birthPlace: 'İstanbul',
      birthDate: '1993-05-14',
      email: 'burak.karahan@teknoloji.com',
      phone: '+905324108520',
      photoUrl: 'https://i.pravatar.cc/300?img=33',
    ),
    Person(
      id: 2,
      fullName: 'Selin Özdemir',
      department: 'Siber Güvenlik Departmanı',
      birthPlace: 'Ankara',
      birthDate: '1995-08-22',
      email: 'selin.ozdemir@teknoloji.com',
      phone: '+905443189640',
      photoUrl: 'https://i.pravatar.cc/300?img=47',
    ),
    Person(
      id: 3,
      fullName: 'Emre Çelik',
      department: 'Veri Bilimi ve Yapay Zeka Departmanı',
      birthPlace: 'İzmir',
      birthDate: '1990-11-09',
      email: 'emre.celik@teknoloji.com',
      phone: '+905056721930',
      photoUrl: 'https://i.pravatar.cc/300?img=60',
    ),
    Person(
      id: 4,
      fullName: 'Deniz Aydın',
      department: 'Ürün Yönetimi Departmanı',
      birthPlace: 'Antalya',
      birthDate: '1997-02-19',
      email: 'deniz.aydin@teknoloji.com',
      phone: '+905368914075',
      photoUrl: 'https://i.pravatar.cc/300?img=32',
    ),
    Person(
      id: 5,
      fullName: 'Kaan Yıldırım',
      department: 'Bulut Altyapı ve Sistem Departmanı',
      birthPlace: 'Bursa',
      birthDate: '1992-07-04',
      email: 'kaan.yildirim@teknoloji.com',
      phone: '+905337452810',
      photoUrl: 'https://i.pravatar.cc/300?img=53',
    ),
    Person(
      id: 6,
      fullName: 'Elif Şahin',
      department: 'İnsan Kaynakları Departmanı',
      birthPlace: 'Eskişehir',
      birthDate: '1996-10-27',
      email: 'elif.sahin@teknoloji.com',
      phone: '+905429036184',
      photoUrl: 'https://i.pravatar.cc/300?img=44',
    ),
  ];

  // ---------------- KİŞİLER ----------------

  static Future<List<Person>> loadPersons() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_personsKey);
    if (raw == null) {
      // İlk açılışta önbellek henüz yoksa başlangıç verilerini kaydet ve döndür
      await savePersons(_initialPersons);
      return List<Person>.from(_initialPersons);
    }
    if (raw.isEmpty) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => Person.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> savePersons(List<Person> persons) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _personsKey,
      jsonEncode(persons.map((p) => p.toLocalJson()).toList()),
    );
  }

  /// Kişiyi ekler; aynı id'li kayıt varsa onu günceller.
  static Future<void> upsert(Person person) async {
    final list = await loadPersons();
    final i = list.indexWhere((p) => p.id == person.id);
    if (i == -1) {
      list.add(person);
    } else {
      list[i] = person;
    }
    await savePersons(list);
  }

  static Future<void> remove(int id) async {
    final list = await loadPersons();
    list.removeWhere((p) => p.id == id);
    await savePersons(list);
  }

  // ---------------- BEKLEYEN İŞLEMLER (KUYRUK) ----------------
  // Her işlem bir Map: {'type': 'create'|'update'|'delete', 'id': int, 'data': {...}}
  // create için 'id' geçici (negatif) yerel id'dir.

  static Future<List<Map<String, dynamic>>> loadOps() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_opsKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> saveOps(List<Map<String, dynamic>> ops) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_opsKey, jsonEncode(ops));
  }
}
