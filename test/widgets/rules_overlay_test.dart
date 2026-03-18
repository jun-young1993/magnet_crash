import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnet_crash/widgets/rules_overlay.dart';

void main() {
  testWidgets('RulesOverlay — W/S/R/C 타입 텍스트 모두 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: RulesOverlay()),
        ),
      ),
    );

    expect(find.textContaining('Weak'), findsWidgets);
    expect(find.textContaining('Strong'), findsWidgets);
    expect(find.textContaining('Repel'), findsWidgets);
    expect(find.textContaining('Chain'), findsWidgets);
  });

  testWidgets('RulesOverlay — How to Play 헤더 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: RulesOverlay()),
        ),
      ),
    );

    expect(find.text('How to Play'), findsOneWidget);
  });

  testWidgets('RulesOverlay — Got it 버튼 탭 시 팝', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const RulesOverlay(),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('How to Play'), findsOneWidget);

    await tester.ensureVisible(find.text('Got it!'));
    await tester.tap(find.text('Got it!'));
    await tester.pumpAndSettle();
    expect(find.text('How to Play'), findsNothing);
  });
}
