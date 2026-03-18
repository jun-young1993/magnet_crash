import 'package:flutter/material.dart';

import '../models/magnet_type.dart';

abstract class GameColors {
  static const p1Color = Color(0xFF4FC3F7);
  static const p2Color = Color(0xFFEF9A9A);
  static const neutralColor = Color(0xFF9E9E9E);

  static Color ownerColor(int ownerId) => switch (ownerId) {
        0 => p1Color,
        1 => p2Color,
        _ => neutralColor,
      };

  static Color typeAccent(MagnetType type) => switch (type) {
        MagnetType.weak => const Color(0xFFE0E0E0),
        MagnetType.strong => const Color(0xFFFFD54F),
        MagnetType.repel => const Color(0xFF69F0AE),
        MagnetType.chain => const Color(0xFFCE93D8),
      };
}
