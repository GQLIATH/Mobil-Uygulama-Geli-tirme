import 'dart:convert';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Etrafında yeşil gradyan halka ve yumuşak parlama olan dairesel profil resmi.
class GlowAvatar extends StatefulWidget {
  final String photoUrl;
  final double radius;

  const GlowAvatar({super.key, required this.photoUrl, this.radius = 28});

  @override
  State<GlowAvatar> createState() => _GlowAvatarState();
}

class _GlowAvatarState extends State<GlowAvatar> {
  bool _loadFailed = false;

  @override
  void didUpdateWidget(covariant GlowAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl) {
      _loadFailed = false;
    }
  }

  /// Hem internet adresini (http/https) hem de cihazdan seçilen
  /// Base64 (data:image/...) fotoğrafı destekler.
  ImageProvider? _buildImageProvider() {
    if (_loadFailed) return null;
    final trimmed = widget.photoUrl.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('data:image')) {
      try {
        final commaIndex = trimmed.indexOf(',');
        if (commaIndex != -1) {
          final bytes = base64Decode(trimmed.substring(commaIndex + 1));
          return MemoryImage(bytes);
        }
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _buildImageProvider();
    final radius = widget.radius;

    return Container(
      padding: EdgeInsets.all(radius > 40 ? 4 : 2.5), // halka kalınlığı
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.green, AppColors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          // Dışa doğru yumuşak yeşil ışıma
          BoxShadow(
            color: AppColors.green.fade(0.35),
            blurRadius: radius * 0.6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceHigh,
        // Ağdan veya cihazdan gelen resim; adres boşsa veya çevrimdışıysa ikon gösterilir
        backgroundImage: imageProvider,
        onBackgroundImageError: imageProvider != null
            ? (_, _) {
                if (mounted && !_loadFailed) {
                  setState(() => _loadFailed = true);
                }
              }
            : null,
        child: imageProvider == null
            ? Icon(Icons.person, size: radius, color: AppColors.green)
            : null,
      ),
    );
  }
}
