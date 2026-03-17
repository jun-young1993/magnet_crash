import 'package:flutter_test/flutter_test.dart';
import 'package:magnet_crash/engine/game_engine.dart';
import 'package:magnet_crash/models/magnet.dart';
import 'package:magnet_crash/models/magnet_type.dart';

Magnet _m(String id, int groupId) =>
    Magnet(id: id, x: 0.5, y: 0.5, type: MagnetType.weak, groupId: groupId, ownerId: -1);

void main() {
  final engine = GameEngine();

  group('checkWinCondition', () {
    test('groupId {0,1} → true (게임 종료)', () {
      final magnets = [_m('a', 0), _m('b', 0), _m('c', 1), _m('d', 1)];
      expect(engine.checkWinCondition(magnets), isTrue);
    });

    test('groupId {0,1,2} → false (게임 계속)', () {
      final magnets = [_m('a', 0), _m('b', 1), _m('c', 2)];
      expect(engine.checkWinCondition(magnets), isFalse);
    });
  });
}
