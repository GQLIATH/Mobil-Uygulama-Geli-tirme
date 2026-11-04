import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Detay sayfasındaki tek bir bilgi satırı (ikon + etiket + değer).
/// onTap verilirse satır tıklanabilir olur ve sağda aksiyon etiketi + ok görünür.
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final String? actionLabel;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = onTap != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          mouseCursor:
              isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onTap: onTap, // null ise InkWell dokunmaya tepki vermez
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface.fade(0.9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isClickable
                    ? AppColors.green.fade(0.32)
                    : AppColors.green.fade(0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green.fade(0.14),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.green),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        value.isEmpty ? '-' : value,
                        style: TextStyle(
                          color: isClickable ? AppColors.green : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isClickable) ...[
                  if (actionLabel != null)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.green.fade(0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        actionLabel!,
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.green),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
