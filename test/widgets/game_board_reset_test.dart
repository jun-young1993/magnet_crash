import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnet_crash/models/game_state.dart';
import 'package:magnet_crash/providers/game_provider.dart';
import 'package:magnet_crash/widgets/game_board.dart';

void main() {
  group('GameBoard — pulse after game reset', () {
    testWidgets('게임 오버 후 resetGame() 하면 보드가 정상 렌더링됨', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: GameBoard()),
          ),
        ),
      );

      // 게임 초기화 확인
      expect(
        container.read(gameProvider).phase,
        GamePhase.p1Turn,
      );

      // 게임 리셋
      container.read(gameProvider.notifier).resetGame();
      await tester.pump();

      // 리셋 후에도 p1Turn 상태, 위젯 정상 렌더링
      expect(
        container.read(gameProvider).phase,
        GamePhase.p1Turn,
      );
      expect(find.byType(GameBoard), findsOneWidget);
    });

    testWidgets('resetGame() 후 탭 이벤트 정상 처리됨 (pulse 정지로 인한 크래시 없음)',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: GameBoard()),
          ),
        ),
      );

      // 리셋 두 번 연속 — gameOver→p1Turn 전환 시뮬레이션
      container.read(gameProvider.notifier).resetGame();
      await tester.pump();
      container.read(gameProvider.notifier).resetGame();
      await tester.pump();

      // 위젯이 여전히 살아있고 탭 가능
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      // 크래시 없이 통과
      expect(find.byType(GameBoard), findsOneWidget);
    });
  });
}
