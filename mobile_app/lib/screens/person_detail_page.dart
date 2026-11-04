import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/person.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glow_avatar.dart';
import '../widgets/info_tile.dart';
import '../widgets/particle_background.dart';
import 'person_form_page.dart';

class PersonDetailPage extends StatefulWidget {
  final int personId; // listeden gelen benzersiz ID
  const PersonDetailPage({super.key, required this.personId});

  @override
  State<PersonDetailPage> createState() => _PersonDetailPageState();
}

class _PersonDetailPageState extends State<PersonDetailPage> {
  late Future<Person> _futurePerson;
  // Bu ekranda bir değişiklik olduysa listeye "tazele" demek için
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _futurePerson = ApiService.getById(widget.personId); // GET /api/persons/{id}
  }

  /// Sistemin e-posta gönderme niyetini (mailto: intent) tetikler.
  Future<void> _launchEmail(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: cleanEmail);
    await _launchUri(uri);
  }

  /// Sistemin arama yapma niyetini (tel: intent) tetikler.
  Future<void> _launchPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    await _launchUri(uri);
  }

  /// Verilen tel: veya mailto: URI'sini sistemin ilgili uygulamasında açar.
  Future<void> _launchUri(Uri uri) async {
    try {
      var ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!ok && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('İlgili uygulama açılamadı')));
      }
    } catch (_) {
      try {
        final ok = await launchUrl(uri);
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('İlgili uygulama açılamadı')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Uygulama açılamadı: $e')));
        }
      }
    }
  }

  Future<void> _edit(Person person) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PersonFormPage(person: person)),
    );
    if (saved == true) {
      _changed = true;
      setState(() {
        _futurePerson = ApiService.getById(widget.personId); // yenile
      });
    }
  }

  Future<void> _delete(Person person) async {
    // Onay diyaloğu: true (Sil) / false (Vazgeç) döner
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Kişiyi sil'),
        content: Text('${person.fullName} kalıcı olarak silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ApiService.delete(person.id!); // DELETE isteği
      if (mounted) Navigator.pop(context, true); // listeye dön, "tazele" de
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Geri tuşuna basılınca da listeye _changed bilgisi gitsin diye PopScope
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: ParticleBackground()),
            SafeArea(
              child: Column(
                children: [
                  // Üst çubuk: yuvarlak geri butonu + başlık
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context, _changed),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surface,
                          ),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Kişi Detay Bilgileri',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<Person>(
                      future: _futurePerson,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Hata: ${snapshot.error}',
                                style:
                                    const TextStyle(color: AppColors.muted)),
                          );
                        }
                        return _buildContent(snapshot.data!);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Person p) {
    final departmentText = p.department.trim().isEmpty
        ? 'Departman Belirtilmedi'
        : p.department.trim();

    return Column(
      children: [
        // Kaydırılabilir üst bölüm
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            children: [
              // Avatar boyutu ekran genişliğine göre ölçeklenir (44 - 64 arası)
              Center(
                child: GlowAvatar(
                  photoUrl: p.photoUrl,
                  radius: (MediaQuery.sizeOf(context).width * 0.17)
                      .clamp(44.0, 64.0)
                      .toDouble(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                p.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Departman: yuvarlak hap (chip) şeklinde
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.green.fade(0.14),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.green.fade(0.4)),
                  ),
                  child: Text(
                    departmentText,
                    style: const TextStyle(
                        color: AppColors.green, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              InfoTile(
                icon: Icons.business_center_rounded,
                label: 'Departman',
                value: departmentText,
              ),
              InfoTile(
                icon: Icons.location_city_rounded,
                label: 'Doğum Yeri',
                value: p.birthPlace,
              ),
              InfoTile(
                icon: Icons.cake_rounded,
                label: 'Doğum Tarihi',
                value: p.birthDate,
              ),
              // Tıklanabilir: e-posta uygulamasını (mailto: intent) açar
              InfoTile(
                icon: Icons.email_rounded,
                label: 'E-posta',
                value: p.email,
                actionLabel: 'E-posta Gönder',
                onTap: p.email.trim().isEmpty
                    ? null
                    : () => _launchEmail(p.email),
              ),
              // Tıklanabilir: arama uygulamasını (tel: intent) açar
              InfoTile(
                icon: Icons.phone_rounded,
                label: 'Telefon',
                value: p.phone,
                actionLabel: 'Ara',
                onTap: p.phone.trim().isEmpty
                    ? null
                    : () => _launchPhone(p.phone),
              ),
            ],
          ),
        ),
        // En altta sabit butonlar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _edit(p),
                  // Dar ekranda yazı taşmasın diye iç boşluk küçük
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  // FittedBox: yazı sığmazsa kendini küçültür, asla taşmaz
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('DÜZENLE'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _delete(p),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  icon: const Icon(Icons.delete_rounded, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('KİŞİYİ SİL'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
