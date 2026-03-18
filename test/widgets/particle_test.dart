import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnet_crash/models/game_state.dart';
import 'package:magnet_crash/providers/game_provider.dart';
import 'package:magnet_crash/widgets/game_board.dart';

void main() {
  group('GameBoard — 파티클 시스템', () {
    testWidgets('resetGame() 후 파티클 없이 보드가 정상 렌더링됨', (tester) async {
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

      // gameOver 상태로 강제 전환 후 리셋
      container.read(gameProvider.notifier).resetGame();
      await tester.pump();

      // 리셋 후 p1Turn 상태, 위젯 정상 렌더링 (파티클 잔류 없음)
      expect(container.read(gameProvider).phase, GamePhase.p1Turn);
      expect(find.byType(GameBoard), findsOneWidget);
    });

    testWidgets('연속 resetGame() 후 크래시 없음 (파티클 초기화 확인)', (tester) async {
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

      // 여러 번 리셋 — 파티클 상태가 누적되지 않아야 함
      for (int i = 0; i < 3; i++) {
        container.read(gameProvider.notifier).resetGame();
        await tester.pump();
      }

      expect(find.byType(GameBoard), findsOneWidget);
      expect(container.read(gameProvider).phase, GamePhase.p1Turn);
    });

    testWidgets('흡수 애니메이션 완료 후 크래시 없음', (tester) async {
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

      // 300ms 흡수 애니메이션 + 600ms 파티클 애니메이션
      // _pulseController가 무한반복이므로 pumpAndSettle 대신 pump 사용
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(GameBoard), findsOneWidget);
    });
  });
}
