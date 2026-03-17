import 'package:flutter_test/flutter_test.dart';
import 'package:magnet_crash/engine/physics.dart';
import 'package:magnet_crash/models/magnet.dart';
import 'package:magnet_crash/models/magnet_type.dart';

Magnet _m(String id, double x, double y, {int groupId = 0}) =>
    Magnet(id: id, x: x, y: y, type: MagnetType.weak, groupId: groupId, ownerId: -1);

void main() {
  group('computeChainAbsorptions', () {
    test('2차 흡수 발생 + 중복 없음 검증', () {
      // 1차 흡수된 자석
      final absorbed = [_m('a1', 0.5, 0.5, groupId: 1)];

      // 1차 흡수 자석 근처(0.10) → 2차 흡수 대상
      final secondary = _m('s1', 0.55, 0.5, groupId: 2);
      // 먼 자석 → 2차 흡수 대상 아님
      final distant = _m('d1', 0.9, 0.9, groupId: 3);
      // 1차와 명확히 범위 내(0.12) → 2차 흡수 대상
      final nearby = _m('near', 0.5, 0.62, groupId: 4);

      final result = computeChainAbsorptions(absorbed, [secondary, distant, nearby]);

      final ids = result.map((m) => m.id).toSet();
      expect(ids, contains('s1'));
      expect(ids, isNot(contains('d1')));
      expect(ids, contains('near'));

      // 중복 없음
      expect(ids.length, equals(result.length));
    });
  });
}
