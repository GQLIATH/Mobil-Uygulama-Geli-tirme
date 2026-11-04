import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/person.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glow_avatar.dart';
import '../widgets/particle_background.dart';

/// Hem "yeni kişi ekle" hem "düzenle" için kullanılan form.
/// person null ise ekleme (POST), doluysa düzenleme (PUT) yapılır.
class PersonFormPage extends StatefulWidget {
  final Person? person;
  const PersonFormPage({super.key, this.person});

  @override
  State<PersonFormPage> createState() => _PersonFormPageState();
}

class _PersonFormPageState extends State<PersonFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Her alanın yazılan metnini tutan denetleyiciler
  late final TextEditingController _name;
  late final TextEditingController _department;
  late final TextEditingController _birthPlace;
  late final TextEditingController _birthDate;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  // Profil fotoğrafı: internet adresi veya cihazdan seçilen resmin
  // "data:image/...;base64,..." hali. Boş ise varsayılan ikon gösterilir.
  String _photo = '';

  bool get _isEdit => widget.person != null;

  @override
  void initState() {
    super.initState();
    final p = widget.person; // düzenlemede mevcut değerlerle doldur
    _name = TextEditingController(text: p?.fullName ?? '');
    _department = TextEditingController(text: p?.department ?? '');
    _photo = p?.photoUrl ?? '';
    _birthPlace = TextEditingController(text: p?.birthPlace ?? '');
    _birthDate = TextEditingController(text: p?.birthDate ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _phone = TextEditingController(text: p?.phone ?? '');
  }

  @override
  void dispose() {
    // Denetleyicileri bellekten temizle
    for (final c in [_name, _department, _birthPlace, _birthDate, _email, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Telefonda galeriyi, bilgisayarda (Chrome / Windows) dosya gezginini açar.
  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        // Küçültüp sıkıştırıyoruz: veri hem cihazda hem sunucuda az yer kaplasın
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (file == null) return; // kullanıcı vazgeçti
      final bytes = await file.readAsBytes();
      final name = file.name.toLowerCase();
      final mime = file.mimeType ??
          (name.endsWith('.png')
              ? 'image/png'
              : name.endsWith('.webp')
                  ? 'image/webp'
                  : name.endsWith('.gif')
                      ? 'image/gif'
                      : 'image/jpeg');
      setState(() => _photo = 'data:$mime;base64,${base64Encode(bytes)}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Fotoğraf seçilemedi: $e')));
      }
    }
  }

  Widget _photoPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // Avatara tıklayınca da fotoğraf seçilir
          GestureDetector(
            onTap: _pickPhoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GlowAvatar(photoUrl: _photo, radius: 52),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.green,
                      border: Border.all(color: AppColors.bg, width: 3),
                    ),
                    child: const Icon(Icons.photo_camera_rounded,
                        size: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: Text(_photo.isEmpty ? 'Fotoğraf Yükle' : 'Değiştir'),
              ),
              if (_photo.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => _photo = ''),
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Kaldır'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_birthDate.text) ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Sunucu "YYYY-MM-DD" bekliyor
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      _birthDate.text = '${picked.year}-$m-$d';
    }
  }

  Future<void> _save() async {
    // Tüm alanların doğrulamasını (validator) çalıştır
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final person = Person(
      fullName: _name.text.trim(),
      department: _department.text.trim(),
      photoUrl: _photo,
      birthPlace: _birthPlace.text.trim(),
      birthDate: _birthDate.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
    );

    try {
      if (_isEdit) {
        await ApiService.update(widget.person!.id!, person); // PUT
      } else {
        await ApiService.create(person); // POST
      }
      if (mounted) Navigator.pop(context, true); // "kaydedildi" diye dön
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                        ),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isEdit ? 'Kişiyi Düzenle' : 'Yeni Kişi',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      // Listeyi sürükleyince klavye kapansın
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(20),
                      children: [
                        _photoPicker(),
                        _field(_name, 'Ad Soyad', required: true),
                        _field(_department, 'Departman', required: true),
                        _field(_birthPlace, 'Doğum Yeri'),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: TextFormField(
                            controller: _birthDate,
                            readOnly: true, // elle yazılmaz, takvimden seçilir
                            onTap: _pickDate,
                            decoration: const InputDecoration(
                              labelText: 'Doğum Tarihi',
                              suffixIcon: Icon(Icons.calendar_today_rounded),
                            ),
                          ),
                        ),
                        _field(_email, 'E-posta', keyboard: TextInputType.emailAddress),
                        _field(_phone, 'Telefon', keyboard: TextInputType.phone),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          // Tam genişlik (temada artık sadece 64 genişlik var)
                          style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(54)),
                          child: _saving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.black),
                                )
                              : const Text('KAYDET'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label boş olamaz' : null
            : null,
      ),
    );
  }
}
