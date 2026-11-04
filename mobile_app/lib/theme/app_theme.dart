import 'package:flutter/material.dart';

/// Uygulamanın tüm renkleri tek yerde. Rengi değiştirmek için sadece buraya bak.
class AppColors {
  static const bg = Color(0xFF070B09); // neredeyse siyah (hafif yeşil tonlu)
  static const surface = Color(0xFF111A15); // kart zemini
  static const surfaceHigh = Color(0xFF17231C); // biraz daha açık zemin
  static const green = Color(0xFF00E676); // ana vurgu rengi (neon yeşil)
  static const teal = Color(0xFF1DE9B6); // gradyan için ikinci renk
  static const muted = Color(0xFF8FA89A); // soluk yazı rengi
  static const danger = Color(0xFFFF5252); // silme butonu
}

/// Color için kısayol: rengin opaklığını 0.0 - 1.0 arasında ayarlar.
/// (withOpacity bazı Flutter sürümlerinde uyarı verdiği için withAlpha kullanıldı.)
extension ColorFade on Color {
  Color fade(double opacity) => withAlpha((opacity * 255).round());
}

/// Tüm uygulamanın teması. main.dart bunu MaterialApp'e verir.
ThemeData buildAppTheme() {
  const radius = 20.0;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.green,
      onPrimary: Colors.black,
      secondary: AppColors.teal,
      surface: AppColors.surface,
      onSurface: Colors.white,
      error: AppColors.danger,
    ),

    // Form alanları: dolgulu, yuvarlak köşeli, odakta yeşil çerçeve
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.muted),
      floatingLabelStyle: const TextStyle(color: AppColors.green),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: AppColors.green.fade(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    ),

    // + butonu (FAB): yuvarlak, yeşil
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.green,
      foregroundColor: Colors.black,
      shape: CircleBorder(),
      elevation: 8,
    ),

    // Dolu butonlar (Kaydet vb.): hap şeklinde
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.black,
        // Genişlik 64: yan yana (Row) konulunca taşma olmasın. Tam genişlik
        // gereken yerde butona ayrıca Size.fromHeight(54) verilir.
        minimumSize: const Size(64, 54),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),

    // Çerçeveli butonlar (Düzenle)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.green,
        // Genişlik 64: yan yana (Row) konulunca taşma olmasın. Tam genişlik
        // gereken yerde butona ayrıca Size.fromHeight(54) verilir.
        minimumSize: const Size(64, 54),
        side: BorderSide(color: AppColors.green.fade(0.6)),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.green),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
