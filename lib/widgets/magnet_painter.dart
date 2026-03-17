import 'package:flutter/material.dart';

import '../engine/physics.dart' as physics;
import '../models/game_state.dart';
import '../models/magnet.dart';
import '../models/magnet_type.dart';

class MagnetPainter extends CustomPainter {
  final GameState gameState;
  final Map<String, Offset> animationOffsets;

  const MagnetPainter({
    required this.gameState,
    this.animationOffsets = const {},
  });

  static const double _radius = 18.0;

  Color _ownerColor(Magnet m) => switch (m.ownerId) {
        0 => const Color(0xFF4FC3F7),
        1 => const Color(0xFFEF9A9A),
        _ => const Color(0xFF9E9E9E),
      };

  Color _typeAccent(MagnetType type) => switch (type) {
        MagnetType.weak => const Color(0xFFE0E0E0),
        MagnetType.strong => const Color(0xFFFFD54F),
        MagnetType.repel => const Color(0xFF69F0AE),
        MagnetType.chain => const Color(0xFFCE93D8),
      };

  String _typeLabel(MagnetType type) => switch (type) {
        MagnetType.weak => 'W',
        MagnetType.strong => 'S',
        MagnetType.repel => 'R',
        MagnetType.chain => 'C',
      };

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    for (final magnet in gameState.magnets) {
      final isAbsorbing = gameState.absorbingIds?.contains(magnet.id) ?? false;
      final isSelected = magnet.id == gameState.selectedMagnetId;

      final Offset center;
      if (animationOffsets.containsKey(magnet.id)) {
        center = animationOffsets[magnet.id]!;
      } else {
        center = Offset(magnet.x * size.width, magnet.y * size.height);
      }

      // 선택 자석의 흡수 범위 미리보기
      if (isSelected && gameState.phase != GamePhase.animating) {
        final r = physics.absorbRadius(magnet.type) * size.width;
        if (r > 0) {
          canvas.drawCircle(
            center,
            r,
            Paint()
              ..color = _ownerColor(magnet).withValues(alpha: 0.12)
              ..style = PaintingStyle.fill,
          );
          canvas.drawCircle(
            center,
            r,
            Paint()
              ..color = _ownerColor(magnet).withValues(alpha: 0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0,
          );
        }
      }

      // 자석 본체
      final double alpha = isAbsorbing ? 0.5 : 1.0;
      final ownerColor = _ownerColor(magnet).withValues(alpha: alpha);

      canvas.drawCircle(center, _radius, Paint()..color = ownerColor);

      // 내부 타입 표시 원
      canvas.drawCircle(
        center,
        _radius * 0.45,
        Paint()
          ..color = _typeAccent(magnet.type).withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );

      // 테두리 링
      canvas.drawCircle(
        center,
        _radius,
        Paint()
          ..color = ownerColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      // 선택 링
      if (isSelected) {
        canvas.drawCircle(
          center,
          _radius + 6,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }

      // 타입 레이블
      final tp = TextPainter(
        text: TextSpan(
          text: _typeLabel(magnet.type),
          style: TextStyle(
            color: Colors.black87.withValues(alpha: alpha),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;
    const steps = 10;
    for (int i = 1; i < steps; i++) {
      final x = size.width * i / steps;
      final y = size.height * i / steps;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(MagnetPainter old) =>
      old.gameState != gameState || old.animationOffsets != animationOffsets;
}
