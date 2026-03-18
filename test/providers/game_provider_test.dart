import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnet_crash/models/game_state.dart';
import 'package:magnet_crash/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameNotifier.onBoardTap — invalidTap', () {
    late ProviderContainer container;
    late GameNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(gameProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('중립 자석 탭 → invalidTap == true, 턴 소비 없음', () {
      final before = container.read(gameProvider);
      // 중립 자석은 ownerId == -1, 현재 P1 턴
      expect(before.phase, GamePhase.p1Turn);

      // 중립 자석의 위치 찾기
      final neutral =
          before.magnets.firstWhere((m) => m.ownerId == -1);
      notifier.onBoardTap(neutral.x, neutral.y);

      final after = container.read(gameProvider);
      expect(after.invalidTap, isTrue);
      expect(after.phase, GamePhase.p1Turn); // 턴 소비 없음
    });

    test('상대 자석 탭 → invalidTap == true, 턴 소비 없음', () {
      final before = container.read(gameProvider);
      expect(before.phase, GamePhase.p1Turn);

      // P2 자석 (ownerId == 1)
      final p2Magnet =
          before.magnets.firstWhere((m) => m.ownerId == 1);
      notifier.onBoardTap(p2Magnet.x, p2Magnet.y);

      final after = container.read(gameProvider);
      expect(after.invalidTap, isTrue);
      expect(after.phase, GamePhase.p1Turn);
    });

    test('내 자석(유효) 탭 → invalidTap == false', () {
      final before = container.read(gameProvider);
      expect(before.phase, GamePhase.p1Turn);

      // P1 자석 탭
      final p1Magnet =
          before.magnets.firstWhere((m) => m.ownerId == 0);
      notifier.onBoardTap(p1Magnet.x, p1Magnet.y);

      final after = container.read(gameProvider);
      expect(after.invalidTap, isFalse);
    });

    test('clearInvalidTap() → invalidTap == false', () {
      final p2Magnet =
          container.read(gameProvider).magnets.firstWhere((m) => m.ownerId == 1);
      notifier.onBoardTap(p2Magnet.x, p2Magnet.y);
      expect(container.read(gameProvider).invalidTap, isTrue);

      notifier.clearInvalidTap();
      expect(container.read(gameProvider).invalidTap, isFalse);
    });
  });
}
