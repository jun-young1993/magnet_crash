import 'package:flutter/material.dart';

import '../constants/game_colors.dart';
import '../engine/physics.dart' as physics;
import '../models/game_state.dart';
import '../models/magnet_type.dart';

/// 흡수 완료 시 터지는 파티클 하나를 나타냄.
/// [origin]에서 [velocity] 방향으로 날아가며 [position(t)]으로 위치 계산.
class Particle {
  final Offset origin;
  final Offset velocity; // pixels per animation unit (t=0~1)
  final Color color;

  const Particle({
    required this.origin,
    required this.velocity,
    required this.color,
  });

  Offset position(double t) => origin + velocity * t;
}

class MagnetPainter extends CustomPainter {
  final GameState gameState;
  final Map<String, Offset> animationOffsets;
  final double pulseValue;
  final List<Particle> particles;
  final double particleProgress; // 0~1

  const MagnetPainter({
    required this.gameState,
    this.animationOffsets = const {},
    this.pulseValue = 0.0,
    this.particles = const [],
    this.particleProgress = 0.0,
  });

  static const double _radius = 18.0;

  String _typeLabel(MagnetType type) => switch (type) {
        MagnetType.weak => 'W',
        MagnetType.strong => 'S',
        MagnetType.repel => 'R',
        MagnetType.chain => 'C',
      };

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    final currentOwnerId = switch (gameState.phase) {
      GamePhase.p1Turn => 0,
      GamePhase.p2Turn => 1,
      _ => -1,
    };

    for (final magnet in gameState.magnets) {
      final isAbsorbing = gameState.absorbingIds?.contains(magnet.id) ?? false;
      final isSelected = magnet.id == gameState.selectedMagnetId;
      final isCurrentPlayerMagnet =
          magnet.ownerId == currentOwnerId && currentOwnerId >= 0;

      final Offset center;
      if (animationOffsets.containsKey(magnet.id)) {
        center = animationOffsets[magnet.id]!;
      } else {
        center = Offset(magnet.x * size.width, magnet.y * size.height);
      }

      // 현재 플레이어 소유 자석 pulse ring
      if (isCurrentPlayerMagnet && gameState.phase != GamePhase.animating) {
        final pulseRadius = _radius + 8 + pulseValue * 6;
        final pulseAlpha = (0.6 - pulseValue * 0.4).clamp(0.2, 0.6);
        canvas.drawCircle(
          center,
          pulseRadius,
          Paint()
            ..color =
                GameColors.ownerColor(magnet.ownerId).withValues(alpha: pulseAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }

      // 선택 자석의 흡수 범위 미리보기
      if (isSelected && gameState.phase != GamePhase.animating) {
        final r = physics.absorbRadius(magnet.type) * size.width;
        if (r > 0) {
          canvas.drawCircle(
            center,
            r,
            Paint()
              ..color =
                  GameColors.ownerColor(magnet.ownerId).withValues(alpha: 0.12)
              ..style = PaintingStyle.fill,
          );
          canvas.drawCircle(
            center,
            r,
            Paint()
              ..color =
                  GameColors.ownerColor(magnet.ownerId).withValues(alpha: 0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0,
          );
        }
      }

      // 자석 본체
      final double alpha = isAbsorbing ? 0.5 : 1.0;
      final ownerColor =
          GameColors.ownerColor(magnet.ownerId).withValues(alpha: alpha);

      canvas.drawCircle(center, _radius, Paint()..color = ownerColor);

      // 내부 타입 표시 원
      canvas.drawCircle(
        center,
        _radius * 0.45,
        Paint()
          ..color = GameColors.typeAccent(magnet.type).withValues(alpha: alpha)
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

    // 파티클 렌더링 (모든 자석 위에)
    if (particles.isNotEmpty && particleProgress > 0) {
      final particlePaint = Paint()..style = PaintingStyle.fill;
      for (final p in particles) {
        final pos = p.position(particleProgress);
        final alpha = (1.0 - particleProgress).clamp(0.0, 1.0);
        final radius = 4.0 * (1.0 - particleProgress * 0.5);
        particlePaint.color = p.color.withValues(alpha: alpha);
        canvas.drawCircle(pos, radius, particlePaint);
      }
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
      old.gameState != gameState ||
      old.animationOffsets != animationOffsets ||
      old.pulseValue != pulseValue ||
      old.particles != particles ||
      old.particleProgress != particleProgress;
}
