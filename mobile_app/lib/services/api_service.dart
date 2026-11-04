import 'dart:convert';

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, ValueNotifier;
import 'package:http/http.dart' as http;

import '../models/person.dart';
import 'local_store.dart';

/// Sunucu "cevap verdi ama hata kodu döndü" (ör. 400, 404) durumu.
/// Ağ hatasından (sunucuya hiç ulaşılamaması) ayırmak için ayrı bir tür.
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

/// Sunucuyla konuşan tek sınıf. Ekranlar HTTP'yi bilmez, sadece bunu çağırır.
///
/// HİBRİT ÇALIŞMA:
/// - Sunucuya ulaşılırsa her şey sunucudan yapılır, sonuç cihaza da kaydedilir.
/// - Ulaşılamazsa (birkaç saniyelik zaman aşımı) cihazdaki veriler kullanılır;
///   ekleme / düzenleme / silme işlemleri kuyruğa alınır ve sunucu tekrar
///   erişilebilir olduğunda (liste yenilenince) otomatik gönderilir.
class ApiService {
  // ---- SUNUCU ADRESİ AYARI ----
  // Android EMÜLATÖRÜNDE bilgisayarın localhost'u 10.0.2.2'dir.
  // (emülatörün kendi 'localhost'u emülatörün içidir, bilgisayar değil!)
  //
  // GERÇEK TELEFONDA (APK'yı telefona kurarsan) 10.0.2.2 ÇALIŞMAZ.
  // O zaman aşağıya bilgisayarın yerel IP'sini yaz, örn: '192.168.1.20'
  // (Windows'ta bulmak için terminalde: ipconfig -> IPv4 Address)
  // Telefon ve bilgisayar AYNI Wi-Fi'da olmalı.
  static const String androidHost = '10.0.2.2';

  // Chrome / Windows gibi bilgisayarda çalışırken kullanılan adres.
  static const String pcHost = '127.0.0.1';

  /// Çalıştığı platforma göre doğru adresi seçer.
  static String get baseUrl {
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final host = isAndroid ? androidHost : pcHost;
    return 'http://$host:8000/api/persons';
  }

  static const _headers = {'Content-Type': 'application/json; charset=utf-8'};

  // Sunucu bu sürede cevap vermezse "offline" sayılır (sonsuz dönen daire olmasın).
  static const _readTimeout = Duration(milliseconds: 1500);
  static const _writeTimeout = Duration(seconds: 3);

  /// Ekranlar bunu dinleyerek "Çevrimdışı mod" uyarısı gösterebilir.
  static final ValueNotifier<bool> offline = ValueNotifier(false);

  // =====================================================================
  //  EKRANLARIN ÇAĞIRDIĞI METOTLAR
  // =====================================================================

  /// Tüm kişiler. Önce bekleyen offline işlemleri gönderir, sonra listeyi çeker.
  /// Sunucuya ulaşılamazsa cihazdaki son listeyi döndürür.
  static Future<List<Person>> getAll() async {
    try {
      await _syncPending();
      final list = await _remoteGetAll();
      await LocalStore.savePersons(list);
      offline.value = false;
      return list;
    } catch (_) {
      offline.value = true;
      return LocalStore.loadPersons();
    }
  }

  /// Tek kişi. Offline ise (veya kayıt sadece cihazdaysa) yerelden okunur.
  static Future<Person> getById(int id) async {
    if (id > 0 && !offline.value) {
      try {
        final p = await _remoteGetById(id);
        await LocalStore.upsert(p);
        return p;
      } on ServerException {
        rethrow;
      } catch (_) {
        offline.value = true;
      }
    }
    final local = (await LocalStore.loadPersons()).where((p) => p.id == id);
    if (local.isEmpty) throw Exception('Kişi bulunamadı');
    return local.first;
  }

  /// Yeni kişi ekler. Offline ise cihaza geçici (negatif) id ile kaydeder.
  static Future<Person> create(Person person) async {
    if (!offline.value) {
      try {
        final p = await _remoteCreate(person);
        await LocalStore.upsert(p);
        return p;
      } on ServerException {
        rethrow; // sunucu veriyi reddetti (ör. geçersiz e-posta) -> kullanıcıya göster
      } catch (_) {
        offline.value = true;
      }
    }
    final local = person.copyWith(id: -DateTime.now().millisecondsSinceEpoch);
    await LocalStore.upsert(local);
    final ops = await LocalStore.loadOps();
    ops.add({'type': 'create', 'id': local.id, 'data': person.toJson()});
    await LocalStore.saveOps(ops);
    return local;
  }

  /// Kişiyi günceller.
  static Future<Person> update(int id, Person person) async {
    if (id > 0 && !offline.value) {
      try {
        final p = await _remoteUpdate(id, person);
        await LocalStore.upsert(p);
        return p;
      } on ServerException {
        rethrow;
      } catch (_) {
        offline.value = true;
      }
    }
    final local = person.copyWith(id: id);
    await LocalStore.upsert(local);
    final ops = await LocalStore.loadOps();
    if (id < 0) {
      // Henüz sunucuya hiç gitmemiş kayıt: bekleyen 'create' işleminin verisini güncelle
      for (final op in ops) {
        if (op['type'] == 'create' && op['id'] == id) op['data'] = person.toJson();
      }
    } else {
      // Aynı kişi için önceki bekleyen güncellemeyi sil, sonuncusu yeterli
      ops.removeWhere((op) => op['type'] == 'update' && op['id'] == id);
      ops.add({'type': 'update', 'id': id, 'data': person.toJson()});
    }
    await LocalStore.saveOps(ops);
    return local;
  }

  /// Kişiyi siler.
  static Future<void> delete(int id) async {
    if (id > 0 && !offline.value) {
      try {
        await _remoteDelete(id);
        await LocalStore.remove(id);
        return;
      } on ServerException {
        rethrow;
      } catch (_) {
        offline.value = true;
      }
    }
    await LocalStore.remove(id);
    final ops = await LocalStore.loadOps();
    // Bu kişiyle ilgili bekleyen tüm işlemler artık gereksiz
    ops.removeWhere((op) => op['id'] == id);
    if (id > 0) ops.add({'type': 'delete', 'id': id});
    await LocalStore.saveOps(ops);
  }

  // =====================================================================
  //  OFFLINE KUYRUĞUNU SUNUCUYA GÖNDERME
  // =====================================================================

  static Future<void> _syncPending() async {
    final ops = await LocalStore.loadOps();
    while (ops.isNotEmpty) {
      final op = ops.first;
      try {
        switch (op['type']) {
          case 'create':
            await _remoteCreate(Person.fromJson(Map<String, dynamic>.from(op['data'])));
          case 'update':
            await _remoteUpdate(
                op['id'] as int, Person.fromJson(Map<String, dynamic>.from(op['data'])));
          case 'delete':
            await _remoteDelete(op['id'] as int);
        }
      } on ServerException {
        // Sunucu bu işlemi reddetti (ör. kişi zaten silinmiş). Kuyruğu
        // kilitlemesin diye bu işlemi atlıyoruz.
      }
      // Ağ hatası olursa buraya gelinmez: hata yukarı fırlar, kuyruk korunur.
      ops.removeAt(0);
      await LocalStore.saveOps(ops);
    }
  }

  // =====================================================================
  //  HTTP İSTEKLERİ (sadece sunucu)
  // =====================================================================

  /// GET /api/persons -> tüm kişiler.
  static Future<List<Person>> _remoteGetAll() async {
    final response = await http.get(Uri.parse(baseUrl)).timeout(_readTimeout);
    if (response.statusCode != 200) {
      throw ServerException('Liste alınamadı (${response.statusCode})');
    }
    // bodyBytes + utf8: Türkçe karakterler bozulmasın diye
    final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
    return list.map((e) => Person.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/persons/{id} -> tek kişi
  static Future<Person> _remoteGetById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id')).timeout(_readTimeout);
    if (response.statusCode != 200) {
      throw ServerException('Kişi bulunamadı (${response.statusCode})');
    }
    return Person.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  /// POST /api/persons -> yeni kişi oluşturur (başarılıysa 201 döner)
  static Future<Person> _remoteCreate(Person person) async {
    final response = await http
        .post(Uri.parse(baseUrl), headers: _headers, body: jsonEncode(person.toJson()))
        .timeout(_writeTimeout);
    if (response.statusCode != 201) {
      throw ServerException(
          'Kayıt eklenemedi (${response.statusCode}) ${utf8.decode(response.bodyBytes)}');
    }
    return Person.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  /// PUT /api/persons/{id} -> kaydı günceller (200 döner)
  static Future<Person> _remoteUpdate(int id, Person person) async {
    final response = await http
        .put(Uri.parse('$baseUrl/$id'), headers: _headers, body: jsonEncode(person.toJson()))
        .timeout(_writeTimeout);
    if (response.statusCode != 200) {
      throw ServerException(
          'Güncellenemedi (${response.statusCode}) ${utf8.decode(response.bodyBytes)}');
    }
    return Person.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  /// DELETE /api/persons/{id} -> kaydı siler (204 No Content döner)
  static Future<void> _remoteDelete(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/$id')).timeout(_writeTimeout);
    if (response.statusCode != 204) {
      throw ServerException('Silinemedi (${response.statusCode})');
    }
  }
}
