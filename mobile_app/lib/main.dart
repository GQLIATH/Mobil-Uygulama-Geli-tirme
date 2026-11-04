import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/person_list_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // SystemChrome (sistem çubukları) çağrılmadan önce Flutter motoru hazır olmalı.
  WidgetsFlutterBinding.ensureInitialized();

  // Telefonda sadece dikey mod: yan çevirince yerleşim sıkışmasın.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Uygulama durum çubuğunun ve alt gezinme çubuğunun arkasına kadar uzansın
  // (edge-to-edge), ikonlar koyu zeminde okunsun diye açık renk olsun.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // Android ikon rengi
    statusBarBrightness: Brightness.dark, // iOS karşılığı
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kişi Yönetimi',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(), // yeşil-siyah koyu tema (theme/app_theme.dart)
      // builder: tüm ekranları saran ortak bir katman.
      builder: (context, child) {
        // Telefonun "yazı boyutu" ayarı çok büyükse arayüz taşmasın diye
        // yazı ölçeğini 0.9 - 1.15 arasında sınırlıyoruz.
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.15,
          child: child!,
        );
      },
      home: const PersonListPage(), // Ana sayfa: kişi listesi
    );
  }
}
