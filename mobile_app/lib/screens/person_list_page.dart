import 'package:flutter/material.dart';

import '../models/person.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/particle_background.dart';
import '../widgets/person_card.dart';
import 'person_detail_page.dart';
import 'person_form_page.dart';

class PersonListPage extends StatefulWidget {
  const PersonListPage({super.key});

  @override
  State<PersonListPage> createState() => _PersonListPageState();
}

class _PersonListPageState extends State<PersonListPage> {
  // Liste isteğinin "ileride gelecek sonucu". FutureBuilder bunu izler.
  late Future<List<Person>> _futurePersons;

  @override
  void initState() {
    super.initState();
    _futurePersons = ApiService.getAll(); // ekran açılınca istek atılır
  }

  /// Listeyi sunucudan yeniden çeker. setState ekranı yeniden çizdirir.
  void _reload() {
    setState(() {
      _futurePersons = ApiService.getAll();
    });
  }

  Future<void> _openDetail(int id) async {
    // Navigator.push: yeni ekran açar ve ekran kapanınca dönen değeri bekler.
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PersonDetailPage(personId: id)),
    );
    if (changed == true) _reload(); // silindi/güncellendiyse listeyi tazele
  }

  Future<void> _openForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PersonFormPage()),
    );
    if (saved == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack: en altta partikül arka planı, üstünde asıl içerik
      body: Stack(
        children: [
          const Positioned.fill(child: ParticleBackground()),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık bölümü
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REHBER',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 13,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kişi Listesi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sunucuya ulaşılamıyorsa küçük bir uyarı şeridi
                ValueListenableBuilder<bool>(
                  valueListenable: ApiService.offline,
                  builder: (context, isOffline, _) {
                    if (!isOffline) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.green.fade(0.25)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.cloud_off_rounded,
                              size: 18, color: AppColors.muted),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Çevrimdışı mod: değişiklikler cihaza kaydedilir, '
                              'sunucuya bağlanınca eşitlenir.',
                              style: TextStyle(
                                  color: AppColors.muted, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(child: _buildList()),
              ],
            ),
          ),
        ],
      ),
      // Sağ altta sabit + butonu (tema: yuvarlak, yeşil)
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<Person>>(
      future: _futurePersons,
      builder: (context, snapshot) {
        // 1) Bekleme durumu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // 2) Hata durumu
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 56, color: AppColors.muted),
                  const SizedBox(height: 16),
                  Text(
                    'Hata: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _reload,
                    style: FilledButton.styleFrom(
                        minimumSize: const Size(160, 48)),
                    child: const Text('Tekrar dene'),
                  ),
                ],
              ),
            ),
          );
        }
        // 3) Veri geldi
        final persons = snapshot.data!;
        if (persons.isEmpty) {
          return const Center(
            child: Text('Kayıtlı kişi yok. + ile ekleyin.',
                style: TextStyle(color: AppColors.muted)),
          );
        }
        // ListView.builder: sadece ekrana sığan satırları üretir (verimli)
        return RefreshIndicator(
          color: AppColors.green,
          backgroundColor: AppColors.surfaceHigh,
          onRefresh: () async => _reload(),
          child: ListView.builder(
            // FAB son kartı kapatmasın diye altta boşluk
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final p = persons[index];
              return PersonCard(
                person: p,
                index: index,
                onTap: () => _openDetail(p.id!), // ID ile detay sayfası
              );
            },
          ),
        );
      },
    );
  }
}
