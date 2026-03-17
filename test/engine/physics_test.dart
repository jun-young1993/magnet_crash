import 'package:flutter_test/flutter_test.dart';
import 'package:magnet_crash/engine/physics.dart';
import 'package:magnet_crash/models/magnet.dart';
import 'package:magnet_crash/models/magnet_type.dart';

Magnet _m(String id, double x, double y,
        {MagnetType type = MagnetType.weak, int groupId = 0, int ownerId = -1}) =>
    Magnet(id: id, x: x, y: y, type: type, groupId: groupId, ownerId: ownerId);

void main() {
  group('distanceBetween', () {
    test('3-4-5 직각삼각형 검증', () {
      final a = _m('a', 0.0, 0.0);
      final b = _m('b', 0.3, 0.4);
      expect(distanceBetween(a, b), closeTo(0.5, 1e-9));
    });
  });

  group('computeAbsorptions', () {
    test('weak(0.15): 범위 내 자석만 흡수', () {
      final selected = _m('sel', 0.0, 0.0, type: MagnetType.weak, groupId: 0, ownerId: 0);
      final inRange = _m('in', 0.10, 0.0, groupId: 1);
      final outRange = _m('out', 0.20, 0.0, groupId: 2);
      final result = computeAbsorptions(selected, [selected, inRange, outRange]);
      expect(result.map((m) => m.id), contains('in'));
      expect(result.map((m) => m.id), isNot(contains('out')));
    });

    test('strong(0.30): 범위 내 자석 흡수', () {
      final selected = _m('sel', 0.0, 0.0, type: MagnetType.strong, groupId: 0, ownerId: 0);
      final inRange = _m('in', 0.25, 0.0, groupId: 1);
      final outRange = _m('out', 0.35, 0.0, groupId: 2);
      final result = computeAbsorptions(selected, [selected, inRange, outRange]);
      expect(result.map((m) => m.id), contains('in'));
      expect(result.map((m) => m.id), isNot(contains('out')));
    });

    test('범위 밖 자석은 흡수 안 함', () {
      final selected = _m('sel', 0.0, 0.0, type: MagnetType.weak, groupId: 0, ownerId: 0);
      final far = _m('far', 0.50, 0.50, groupId: 1);
      final result = computeAbsorptions(selected, [selected, far]);
      expect(result, isEmpty);
    });

    test('같은 groupId 자석은 범위 내여도 흡수 안 함', () {
      final selected = _m('sel', 0.0, 0.0, type: MagnetType.weak, groupId: 0, ownerId: 0);
      final sameGroup = _m('ally', 0.05, 0.0, groupId: 0);
      final result = computeAbsorptions(selected, [selected, sameGroup]);
      expect(result, isEmpty);
    });
  });

  group('computeRepelPositions', () {
    test('반발 후 위치가 0.05~0.95 범위로 clamp됨', () {
      final repeller = _m('rep', 0.01, 0.01, type: MagnetType.repel, groupId: 0, ownerId: 0);
      // 코너 근처 자석 — 밀려나면 경계 밖으로 가야 하지만 clamp됨
      final corner = _m('c', 0.05, 0.05, groupId: 1);
      final result = computeRepelPositions(repeller, [repeller, corner]);
      for (final m in result) {
        expect(m.x, greaterThanOrEqualTo(0.05));
        expect(m.x, lessThanOrEqualTo(0.95));
        expect(m.y, greaterThanOrEqualTo(0.05));
        expect(m.y, lessThanOrEqualTo(0.95));
      }
    });
  });
}
