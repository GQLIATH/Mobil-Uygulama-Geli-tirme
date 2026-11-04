import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tek bir parçacığın SABİT özellikleri. Konumu zamana göre hesaplanır.
class _Particle {
  final double x; // başlangıç yatay konumu (0.0 - 1.0 arası, ekran oranı)
  final double y; // başlangıç dikey konumu (0.0 - 1.0)
  final double size; // nokta yarıçapı
  final double speed; // yukarı çıkış hızı
  final double phase; // sağa-sola salınımın başlangıç açısı
  final double amp; // sağa-sola salınımın genliği

  const _Particle(this.x, this.y, this.size, this.speed, this.phase, this.amp);
}

/// Arka plana yumuşak yeşil ışıma + yukarı doğru süzülen partiküller çizer.
/// Kullanım: Stack içinde en alta koyulur: Positioned.fill(child: ParticleBackground())
class ParticleBackground extends StatefulWidget {
  final int count; // parçacık sayısı
  const ParticleBackground({super.key, this.count = 38});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  // AnimationController: sürekli artan bir sayaç (0.0 -> 1.0, sonra başa döner).
  // Her karede painter'ı yeniden çizdirir. SingleTickerProviderStateMixin
  // ekranın yenilenme hızına (vsync) bağlanmamızı sağlar.
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rnd = Random(7); // sabit tohum: her açılışta aynı dağılım
    _particles = List.generate(widget.count, (_) {
      return _Particle(
        rnd.nextDouble(),
        rnd.nextDouble(),
        1.2 + rnd.nextDouble() * 2.6,
        0.004 + rnd.nextDouble() * 0.012,
        rnd.nextDouble() * 2 * pi,
        0.01 + rnd.nextDouble() * 0.03,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 30), // çok uzun: döngü sıçraması fark edilmez
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose(); // bellek sızıntısını önler
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Arka plan dokunmaları engellemesin
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Sağ üstte yumuşak yeşil ışıma (merkezden kenara doğru şeffaflaşır)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.9, -0.9),
                radius: 1.1,
                colors: [AppColors.green.fade(0.16), Colors.transparent],
              ),
            ),
          ),
          // Sol altta daha soluk ikinci ışıma
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-1.0, 1.0),
                radius: 1.0,
                colors: [AppColors.teal.fade(0.10), Colors.transparent],
              ),
            ),
          ),
          // Parçacıklar. RepaintBoundary: sadece bu katman yeniden çizilsin
          RepaintBoundary(
            child: CustomPaint(
              painter: _ParticlePainter(_particles, _controller),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Animation<double> animation;

  // super(repaint: animation): animasyon her değiştiğinde paint() yeniden çalışır.
  _ParticlePainter(this.particles, this.animation) : super(repaint: animation);

  static const double _totalSeconds = 30 * 60; // controller süresi (saniye)
  static const double _linkDistance = 110; // iki nokta bu mesafeden yakınsa çizgi çek

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * _totalSeconds; // geçen süre (saniye)

    // 1) Her parçacığın o anki konumunu hesapla.
    //    y: zamanla yukarı çıkar (% 1.0: tepeden çıkınca alttan girer)
    //    x: sin ile sağa-sola hafifçe salınır
    final points = <Offset>[];
    for (final p in particles) {
      final dy = (p.y - t * p.speed) % 1.0;
      final dx = (p.x + sin(t * 0.4 + p.phase) * p.amp) % 1.0;
      points.add(Offset(dx * size.width, dy * size.height));
    }

    // 2) Yakın noktalar arasına ince çizgi çek (ağ efekti)
    final linePaint = Paint()..strokeWidth = 1;
    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        final d = (points[i] - points[j]).distance;
        if (d < _linkDistance) {
          // Mesafe arttıkça çizgi soluklaşır
          linePaint.color = AppColors.green.fade((1 - d / _linkDistance) * 0.18);
          canvas.drawLine(points[i], points[j], linePaint);
        }
      }
    }

    // 3) Noktaları çiz: önce büyük soluk daire (parlama), üstüne küçük parlak çekirdek
    final dotPaint = Paint();
    for (var i = 0; i < points.length; i++) {
      final r = particles[i].size;
      dotPaint.color = AppColors.green.fade(0.08);
      canvas.drawCircle(points[i], r * 3, dotPaint);
      dotPaint.color = AppColors.green.fade(0.75);
      canvas.drawCircle(points[i], r, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => false;
}
