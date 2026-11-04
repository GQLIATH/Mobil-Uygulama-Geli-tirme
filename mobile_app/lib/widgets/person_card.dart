import 'dart:math';

import 'package:flutter/material.dart';

import '../models/person.dart';
import '../theme/app_theme.dart';
import 'glow_avatar.dart';

/// Listedeki tek bir kişi kartı. Liste açılırken aşağıdan yukarı yumuşakça belirir.
class PersonCard extends StatelessWidget {
  final Person person;
  final int index; // listedeki sırası (giriş animasyonu gecikmesi için)
  final VoidCallback onTap;

  const PersonCard({
    super.key,
    required this.person,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final departmentText = person.department.trim().isEmpty
        ? 'Departman Belirtilmedi'
        : person.department.trim();

    // TweenAnimationBuilder: 0'dan 1'e giden bir değeri animasyonla üretir.
    // Bu değerle kartın şeffaflığını ve kaymasını ayarlıyoruz.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + min(index, 8) * 70),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 24), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onTap,
            child: Ink(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26), // yumuşak köşeler
                gradient: LinearGradient(
                  colors: [AppColors.surfaceHigh.fade(0.9), AppColors.surface.fade(0.9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.green.fade(0.14)),
              ),
              child: Row(
                children: [
                  GlowAvatar(photoUrl: person.photoUrl, radius: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold, // kalın ad-soyad
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          departmentText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.green.fade(0.12),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
