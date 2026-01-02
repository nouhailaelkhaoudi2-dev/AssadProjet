import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _shrinkController;
  late AnimationController _trophyController;
  late Animation<double> _circleAnimation;
  late Animation<double> _shrinkAnimation;
  late Animation<double> _trophyAnimation;

  @override
  void initState() {
    super.initState();

    // Animation 1: White line going in circles
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _circleAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );

    // Animation 2: Shrink to center point
    _shrinkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shrinkAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _shrinkController, curve: Curves.easeInQuad),
    );

    // Animation 3: Trophy appears
    _trophyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _trophyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _trophyController, curve: Curves.elasticOut),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _circleController.forward();
    await _shrinkController.forward();
    await _trophyController.forward();
    
    // Navigate to welcome page after animation
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  void dispose() {
    _circleController.dispose();
    _shrinkController.dispose();
    _trophyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const deepRed = Color(0xFFC8102E);

    return Scaffold(
      backgroundColor: deepRed,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated circles
            AnimatedBuilder(
              animation: _circleAnimation,
              builder: (context, child) {
                return AnimatedBuilder(
                  animation: _shrinkAnimation,
                  builder: (context, child) {
                    final progress = _circleAnimation.value;
                    final shrink = _shrinkAnimation.value;
                    
                    return CustomPaint(
                      size: Size(300 * shrink, 300 * shrink),
                      painter: CirclePainter(progress: progress),
                    );
                  },
                );
              },
            ),
            
            // Trophy
            AnimatedBuilder(
              animation: _trophyAnimation,
              builder: (context, child) {
                final scale = _trophyAnimation.value;
                return Transform.scale(
                  scale: scale,
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 120,
                  ),
                );
              },
            ),
            
            // AFCON 2025 text
            AnimatedBuilder(
              animation: _trophyAnimation,
              builder: (context, child) {
                final opacity = _trophyAnimation.value;
                return Positioned(
                  bottom: 100,
                  child: Opacity(
                    opacity: opacity,
                    child: const Column(
                      children: [
                        Text(
                          'AFCON',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'CAN 2025',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double progress;

  CirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw multiple circles based on progress
    for (int i = 0; i < progress.floor() + 1; i++) {
      final circleProgress = (progress - i).clamp(0.0, 1.0);
      final radius = size.width / 2 * (0.3 + i * 0.2);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * circleProgress,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
