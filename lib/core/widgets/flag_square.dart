import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Square country flag widget with optional network image and custom painter
class FlagSquare extends StatelessWidget {
  final String code; // ISO alpha-2, e.g., 'MA', 'TZ'
  final String? imageUrl; // Optional network image (team/logo)
  final String emoji; // Fallback emoji
  // Height of the flag. Width will be computed using aspectRatio.
  final double size;
  // Width / height ratio. Default to a wide rectangular flag.
  final double aspectRatio;

  const FlagSquare({
    super.key,
    required this.code,
    required this.emoji,
    this.imageUrl,
    this.size = 44,
    this.aspectRatio = 1.9,
  });

  @override
  Widget build(BuildContext context) {
    final width = size * aspectRatio;
    return SizedBox(width: width, height: size, child: _buildContent());
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => _paintOrEmoji(),
      );
    }
    return _paintOrEmoji();
  }

  Widget _paintOrEmoji() {
    switch (code.toUpperCase()) {
      case 'MA':
        return CustomPaint(painter: _MoroccoFlagPainter());
      case 'TZ':
        return CustomPaint(painter: _TanzaniaFlagPainter());
      case 'NG':
        return CustomPaint(painter: _NigeriaFlagPainter());
      case 'MZ':
        return CustomPaint(painter: _MozambiqueFlagPainter());
      case 'BF':
        return CustomPaint(painter: _BurkinaFasoFlagPainter());
      case 'CM':
        return CustomPaint(painter: _CameroonFlagPainter());
      case 'ZA':
        return CustomPaint(painter: _SouthAfricaFlagPainter());
      case 'EG':
        return CustomPaint(painter: _EgyptFlagPainter());
      case 'SN':
        return CustomPaint(painter: _SenegalFlagPainter());
      case 'DZ':
        return CustomPaint(painter: _AlgeriaFlagPainter());
      case 'CI':
        return CustomPaint(painter: _IvoryCoastFlagPainter());
      case 'BW':
        return CustomPaint(painter: _BotswanaFlagPainter());
      case 'GA':
        return CustomPaint(painter: _GabonFlagPainter());
      case 'ML':
        return CustomPaint(painter: _MaliFlagPainter());
      case 'GH':
        return CustomPaint(painter: _GhanaFlagPainter());
      default:
        return Container(
          alignment: Alignment.center,
          color: const Color(0xFFECECEC),
          child: Text(
            code.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.black87,
            ),
          ),
        );
    }
  }
}

class _MoroccoFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()..color = const Color(0xFFC8102E);
    canvas.drawRect(Offset.zero & size, red);

    // Draw green star (approximate 5-point star)
    final starPaint = Paint()
      ..color = const Color(0xFF006233)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.06;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.28;
    final points = <Offset>[];
    for (int i = 0; i < 5; i++) {
      final angle = -90 + i * 72; // degrees
      final rad = angle * math.pi / 180;
      points.add(
        center + Offset(radius * math.cos(rad), radius * math.sin(rad)),
      );
    }
    // Connect points to make star pentagram
    for (int i = 0; i < 5; i++) {
      final a = points[i];
      final b = points[(i + 2) % 5];
      canvas.drawLine(a, b, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TanzaniaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF1EB53A);
    final blue = Paint()..color = const Color(0xFF00A3DD);
    final black = Paint()..color = Colors.black;
    final yellow = Paint()..color = const Color(0xFFFCD116);

    // Background split: top-left green, bottom-right blue
    final pathTopLeft = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathTopLeft, green);

    final pathBottomRight = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(pathBottomRight, blue);

    // Diagonal band from bottom-left to top-right
    final bandWidth = size.shortestSide * 0.22;
    final diag = Path()
      ..moveTo(0, size.height - bandWidth)
      ..lineTo(bandWidth, size.height)
      ..lineTo(size.width, bandWidth)
      ..lineTo(size.width - bandWidth, 0)
      ..close();

    // Yellow border
    final borderWidth = size.shortestSide * 0.07;
    final yellowPath = Path()..addPath(diag, Offset.zero);
    canvas.drawPath(yellowPath, yellow);

    // Inner black band (shrink by border width)
    final shrink = borderWidth;
    final blackPath = Path()
      ..moveTo(shrink, size.height - bandWidth + shrink)
      ..lineTo(bandWidth - shrink, size.height - shrink)
      ..lineTo(size.width - shrink, bandWidth - shrink)
      ..lineTo(size.width - bandWidth + shrink, shrink)
      ..close();
    canvas.drawPath(blackPath, black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NigeriaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF008751);
    final white = Paint()..color = Colors.white;

    final stripeWidth = size.width / 3;
    // Left green
    canvas.drawRect(Rect.fromLTWH(0, 0, stripeWidth, size.height), green);
    // Middle white
    canvas.drawRect(
      Rect.fromLTWH(stripeWidth, 0, stripeWidth, size.height),
      white,
    );
    // Right green
    canvas.drawRect(
      Rect.fromLTWH(2 * stripeWidth, 0, stripeWidth, size.height),
      green,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// no extras

class _BurkinaFasoFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()..color = const Color(0xFFEF2B2D);
    final green = Paint()..color = const Color(0xFF009E49);
    final yellow = Paint()..color = const Color(0xFFFCD116);

    // Top red half
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height / 2), red);
    // Bottom green half
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
      green,
    );

    // Center star (filled)
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.shortestSide * 0.18;
    final innerR = outerR * 0.5;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final isOuter = i % 2 == 0;
      final r = isOuter ? outerR : innerR;
      final angle = -90 + i * 36; // degrees
      final rad = angle * math.pi / 180;
      final p = center + Offset(r * math.cos(rad), r * math.sin(rad));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MozambiqueFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF007A3D);
    final black = Paint()..color = Colors.black;
    final yellow = Paint()..color = const Color(0xFFFCD116);
    final white = Paint()..color = Colors.white;
    final red = Paint()..color = const Color(0xFFD21034);

    // Stripes: green (top), black (middle), yellow (bottom) with thin white fimbriations
    final stripeH = size.height / 3;
    // Top green
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, stripeH), green);
    // White separator
    canvas.drawRect(Rect.fromLTWH(0, stripeH - 2, size.width, 4), white);
    // Middle black
    canvas.drawRect(Rect.fromLTWH(0, stripeH, size.width, stripeH), black);
    // White separator
    canvas.drawRect(Rect.fromLTWH(0, 2 * stripeH - 2, size.width, 4), white);
    // Bottom yellow
    canvas.drawRect(Rect.fromLTWH(0, 2 * stripeH, size.width, stripeH), yellow);

    // Red triangle at hoist
    final base = size.width * 0.42;
    final tri = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(base, size.height / 2)
      ..close();
    canvas.drawPath(tri, red);

    // Yellow star inside triangle (simple filled star)
    final center = Offset(base * 0.55, size.height / 2);
    final outerR = size.shortestSide * 0.12;
    final innerR = outerR * 0.5;
    final star = Path();
    for (int i = 0; i < 10; i++) {
      final isOuter = i % 2 == 0;
      final r = isOuter ? outerR : innerR;
      final angle = -90 + i * 36;
      final rad = angle * math.pi / 180;
      final p = center + Offset(r * math.cos(rad), r * math.sin(rad));
      if (i == 0) {
        star.moveTo(p.dx, p.dy);
      } else {
        star.lineTo(p.dx, p.dy);
      }
    }
    star.close();
    canvas.drawPath(star, yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CameroonFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF007A5E);
    final red = Paint()..color = const Color(0xFFCE1126);
    final yellow = Paint()..color = const Color(0xFFFCD116);

    final stripeWidth = size.width / 3;
    // Left green
    canvas.drawRect(Rect.fromLTWH(0, 0, stripeWidth, size.height), green);
    // Middle red
    canvas.drawRect(
      Rect.fromLTWH(stripeWidth, 0, stripeWidth, size.height),
      red,
    );
    // Right yellow
    canvas.drawRect(
      Rect.fromLTWH(2 * stripeWidth, 0, stripeWidth, size.height),
      yellow,
    );

    // Yellow star centered on the red stripe
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.shortestSide * 0.18;
    final innerR = outerR * 0.5;
    final star = Path();
    for (int i = 0; i < 10; i++) {
      final isOuter = i % 2 == 0;
      final r = isOuter ? outerR : innerR;
      final angle = -90 + i * 36;
      final rad = angle * math.pi / 180;
      final p = center + Offset(r * math.cos(rad), r * math.sin(rad));
      if (i == 0) {
        star.moveTo(p.dx, p.dy);
      } else {
        star.lineTo(p.dx, p.dy);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFFCD116));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SouthAfricaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()..color = const Color(0xFFDE3831);
    final blue = Paint()..color = const Color(0xFF002395);
    final green = Paint()..color = const Color(0xFF007A4D);
    final black = Paint()..color = Colors.black;
    final yellow = Paint()..color = const Color(0xFFFCD116);
    final white = Paint()..color = Colors.white;

    // Top red band
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height / 2), red);
    // Bottom blue band
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
      blue,
    );

    // Hoist triangle with yellow border and black fill
    final tri = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.45, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    final triBorder = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.47, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(triBorder, yellow);
    canvas.drawPath(tri, black);

    // Green Y-band with white fimbriations
    final yPath = Path()
      ..moveTo(size.width * 0.45, size.height / 2)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.18)
      ..lineTo(size.width * 0.62, size.height / 2)
      ..lineTo(size.width, size.height * 0.82)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.45, size.height / 2)
      ..close();
    final yBorder = Path()
      ..moveTo(size.width * 0.47, size.height / 2)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.15)
      ..lineTo(size.width * 0.60, size.height / 2)
      ..lineTo(size.width, size.height * 0.85)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.47, size.height / 2)
      ..close();
    canvas.drawPath(yBorder, white);
    canvas.drawPath(yPath, green);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EgyptFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()..color = const Color(0xFFCE1126);
    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;
    final gold = Paint()..color = const Color(0xFFFCD116);

    final stripeH = size.height / 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, stripeH), red);
    canvas.drawRect(Rect.fromLTWH(0, stripeH, size.width, stripeH), white);
    canvas.drawRect(Rect.fromLTWH(0, 2 * stripeH, size.width, stripeH), black);

    // Simple golden emblem placeholder at center
    final emblemW = size.width * 0.18;
    final emblemH = size.height * 0.22;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: emblemW,
      height: emblemH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      gold,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SenegalFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF00853F);
    final yellow = Paint()..color = const Color(0xFFFCD116);
    final red = Paint()..color = const Color(0xFFE31B23);

    final stripeW = size.width / 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, stripeW, size.height), green);
    canvas.drawRect(Rect.fromLTWH(stripeW, 0, stripeW, size.height), yellow);
    canvas.drawRect(Rect.fromLTWH(2 * stripeW, 0, stripeW, size.height), red);

    // Green star centered on yellow stripe
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.shortestSide * 0.18;
    final innerR = outerR * 0.5;
    final star = Path();
    for (int i = 0; i < 10; i++) {
      final isOuter = i % 2 == 0;
      final r = isOuter ? outerR : innerR;
      final angle = -90 + i * 36;
      final rad = angle * math.pi / 180;
      final p = center + Offset(r * math.cos(rad), r * math.sin(rad));
      if (i == 0) {
        star.moveTo(p.dx, p.dy);
      } else {
        star.lineTo(p.dx, p.dy);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = const Color(0xFF00853F));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AlgeriaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF006233);
    final white = Paint()..color = Colors.white;
    final red = Paint()..color = const Color(0xFFD21034);

    // Split vertically: green (hoist), white (fly)
    final stripeW = size.width / 2;
    canvas.drawRect(Rect.fromLTWH(0, 0, stripeW, size.height), green);
    canvas.drawRect(Rect.fromLTWH(stripeW, 0, stripeW, size.height), white);

    // Red crescent and star centered
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.shortestSide * 0.32;
    final innerR = outerR * 0.8;

    // Draw crescent using two overlapping circles
    final crescentPath = Path();
    // Outer circle (full moon)
    crescentPath.addOval(Rect.fromCircle(center: center, radius: outerR));
    // Inner circle to cut out (shifted right to create crescent)
    final innerCenter = center.translate(outerR * 0.35, 0);
    final cutoutPath = Path()
      ..addOval(Rect.fromCircle(center: innerCenter, radius: innerR));

    // Combine paths to create crescent
    final crescent = Path.combine(
      PathOperation.difference,
      crescentPath,
      cutoutPath,
    );
    canvas.drawPath(crescent, red);

    // Red star to the right of crescent
    final starCenter = center.translate(outerR * 0.55, 0);
    final starOuter = size.shortestSide * 0.12;
    final starInner = starOuter * 0.4;
    final star = Path();
    for (int i = 0; i < 10; i++) {
      final isOuter = i % 2 == 0;
      final r = isOuter ? starOuter : starInner;
      final angle = -90 + i * 36;
      final rad = angle * math.pi / 180;
      final p = starCenter + Offset(r * math.cos(rad), r * math.sin(rad));
      if (i == 0) {
        star.moveTo(p.dx, p.dy);
      } else {
        star.lineTo(p.dx, p.dy);
      }
    }
    star.close();
    canvas.drawPath(star, red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IvoryCoastFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final orange = Paint()..color = const Color(0xFFF77F00);
    final white = Paint()..color = Colors.white;
    final green = Paint()..color = const Color(0xFF009E60);

    final stripeW = size.width / 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, stripeW, size.height), orange);
    canvas.drawRect(Rect.fromLTWH(stripeW, 0, stripeW, size.height), white);
    canvas.drawRect(Rect.fromLTWH(2 * stripeW, 0, stripeW, size.height), green);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GabonFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF009739);
    final yellow = Paint()..color = const Color(0xFFFCD116);
    final blue = Paint()..color = const Color(0xFF3A75C4);

    final stripeH = size.height / 3;
    // Top green
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, stripeH), green);
    // Middle yellow
    canvas.drawRect(Rect.fromLTWH(0, stripeH, size.width, stripeH), yellow);
    // Bottom blue
    canvas.drawRect(Rect.fromLTWH(0, 2 * stripeH, size.width, stripeH), blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BotswanaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()..color = const Color(0xFF75AADB);
    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;

    // Light blue background
    canvas.drawRect(Offset.zero & size, blue);

    final h = size.height;
    final w = size.width;
    final blackH = h * 0.22; // central black band
    final whiteH = h * 0.06; // white fimbriations
    final centerY = h / 2;

    // Upper white stripe
    canvas.drawRect(
      Rect.fromLTWH(0, centerY - (blackH / 2 + whiteH), w, whiteH),
      white,
    );
    // Black stripe
    canvas.drawRect(Rect.fromLTWH(0, centerY - blackH / 2, w, blackH), black);
    // Lower white stripe
    canvas.drawRect(Rect.fromLTWH(0, centerY + blackH / 2, w, whiteH), white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MaliFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF14B53A);
    final yellow = Paint()..color = const Color(0xFFFCD116);
    final red = Paint()..color = const Color(0xFFCE1126);

    final stripeW = size.width / 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, stripeW, size.height), green);
    canvas.drawRect(Rect.fromLTWH(stripeW, 0, stripeW, size.height), yellow);
    canvas.drawRect(Rect.fromLTWH(2 * stripeW, 0, stripeW, size.height), red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GhanaFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()..color = const Color(0xFFCE1126);
    final yellow = Paint()..color = const Color(0xFFFCD116);
    final green = Paint()..color = const Color(0xFF006B3F);
    final black = Paint()..color = Colors.black;

    final stripeH = size.height / 3;

    // Red stripe (top)
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, stripeH), red);
    // Yellow stripe (middle)
    canvas.drawRect(Rect.fromLTWH(0, stripeH, size.width, stripeH), yellow);
    // Green stripe (bottom)
    canvas.drawRect(Rect.fromLTWH(0, 2 * stripeH, size.width, stripeH), green);

    // Black star in center
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.2;
    final path = Path();

    for (int i = 0; i < 5; i++) {
      final angle = -90 + i * 72;
      final rad = angle * math.pi / 180;
      final point =
          center + Offset(radius * math.cos(rad), radius * math.sin(rad));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // Draw filled star
    final starPath = Path();
    final innerRadius = radius * 0.4;
    for (int i = 0; i < 10; i++) {
      final angle = -90 + i * 36;
      final rad = angle * math.pi / 180;
      final r = i.isEven ? radius : innerRadius;
      final point = center + Offset(r * math.cos(rad), r * math.sin(rad));
      if (i == 0) {
        starPath.moveTo(point.dx, point.dy);
      } else {
        starPath.lineTo(point.dx, point.dy);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
