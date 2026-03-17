import 'dart:math';

import '../models/magnet.dart';
import '../models/magnet_type.dart';

const _tapThreshold = 0.08;
const _repelRadius = 0.20;

double distanceBetween(Magnet a, Magnet b) =>
    sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));

double absorbRadius(MagnetType type) => switch (type) {
      MagnetType.weak => 0.15,
      MagnetType.strong => 0.30,
      MagnetType.chain => 0.15,
      MagnetType.repel => 0.0,
    };

Magnet? findNearestMagnet(double x, double y, List<Magnet> magnets) {
  Magnet? nearest;
  double minDist = _tapThreshold;
  for (final m in magnets) {
    final d = sqrt(pow(m.x - x, 2) + pow(m.y - y, 2));
    if (d < minDist) {
      minDist = d;
      nearest = m;
    }
  }
  return nearest;
}

/// 선택된 자석이 흡수할 자석 목록 반환 (다른 그룹, 범위 내)
List<Magnet> computeAbsorptions(Magnet selected, List<Magnet> allMagnets) {
  if (selected.type == MagnetType.repel) return [];
  final radius = absorbRadius(selected.type);
  return allMagnets
      .where((m) =>
          m.id != selected.id &&
          m.groupId != selected.groupId &&
          distanceBetween(selected, m) <= radius)
      .toList();
}

/// repel: 반경 내 자석들의 새 위치 계산 (벡터 밀어내기)
List<Magnet> computeRepelPositions(Magnet repeller, List<Magnet> allMagnets) {
  final result = <Magnet>[];
  for (final m in allMagnets) {
    if (m.id == repeller.id) continue;
    final d = distanceBetween(repeller, m);
    if (d > _repelRadius) continue;
    if (d < 0.001) {
      result.add(m.copyWith(
        x: (m.x + 0.1).clamp(0.05, 0.95),
        y: (m.y + 0.1).clamp(0.05, 0.95),
      ));
      continue;
    }
    final dirX = (m.x - repeller.x) / d;
    final dirY = (m.y - repeller.y) / d;
    final pushDist = _repelRadius - d + 0.05;
    result.add(m.copyWith(
      x: (m.x + dirX * pushDist).clamp(0.05, 0.95),
      y: (m.y + dirY * pushDist).clamp(0.05, 0.95),
    ));
  }
  return result;
}

/// chain: 1차 흡수 후 2차 흡수 계산
List<Magnet> computeChainAbsorptions(
    List<Magnet> absorbed, List<Magnet> remaining) {
  final absorbedIds = absorbed.map((m) => m.id).toSet();
  final result = <Magnet>[];
  for (final a in absorbed) {
    for (final m in remaining) {
      if (absorbedIds.contains(m.id)) continue;
      if (result.any((r) => r.id == m.id)) continue;
      if (distanceBetween(a, m) <= 0.15) result.add(m);
    }
  }
  return result;
}
