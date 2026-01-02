import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomeMoroccoPage extends StatefulWidget {
  const WelcomeMoroccoPage({super.key});

  @override
  State<WelcomeMoroccoPage> createState() => _WelcomeMoroccoPageState();
}

class _WelcomeMoroccoPageState extends State<WelcomeMoroccoPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color moroccanRed = Color(0xFFC8102E);
    const String networkBackgroundUrl =
        'https://picsum.photos/seed/morocco-football/1200/2400';

    return Scaffold(
      body: Stack(
        children: [
          // Background image from internet (placeholder) + red overlay gradient
          Positioned.fill(
            child: Image.network(
              networkBackgroundUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [moroccanRed, Color(0xFFD63A3A)],
                ),
              ),
            ),
          ),
          // Watermark Moroccan star painter
          const Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: CustomPaint(painter: _MoroccanStarPainter(opacity: 0.08)),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.sports_soccer, color: Colors.white, size: 36),
                      SizedBox(width: 12),
                      _Branding(),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final t = _controller.value;
                            final dy = math.sin(t * math.pi) * 10;
                            return Transform.translate(
                              offset: Offset(0, -20 + dy),
                              child: const Icon(
                                Icons.sports_soccer,
                                color: Colors.white,
                                size: 64,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 280,
                          child: _PrimaryButton(
                            label: 'Register',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 280,
                          child: _PrimaryButton(
                            label: 'Login',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Tikitaka Apps v1.0',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 0.5,
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
}

class _Branding extends StatelessWidget {
  const _Branding();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'TIKITAKA MAROC',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Le foot marocain, facile',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF006233),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _MoroccanStarPainter extends CustomPainter {
  final double opacity;

  const _MoroccanStarPainter({this.opacity = 0.1});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF006233).withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Draw a five-pointed star inspired by the Moroccan flag
    final center = Offset(size.width * 0.5, size.height * 0.35);
    final radius = size.width * 0.35;

    final points = <Offset>[];
    for (int i = 0; i < 5; i++) {
      final angle = (math.pi / 2) + i * (2 * math.pi / 5);
      points.add(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy - radius * math.sin(angle),
        ),
      );
    }

    final path = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..lineTo(points[2].dx, points[2].dy)
      ..lineTo(points[4].dx, points[4].dy)
      ..lineTo(points[1].dx, points[1].dy)
      ..lineTo(points[3].dx, points[3].dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
