import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnet_crash/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('firstLaunchProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('rules_seen 미설정 → true (첫 실행)', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(firstLaunchProvider.future);
      expect(result, isTrue);
    });

    test('rules_seen = true → false (재실행)', () async {
      SharedPreferences.setMockInitialValues({'rules_seen': true});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(firstLaunchProvider.future);
      expect(result, isFalse);
    });

    test('markRulesSeen 후 → false', () async {
      SharedPreferences.setMockInitialValues({});
      await markRulesSeen();

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(firstLaunchProvider.future);
      expect(result, isFalse);
    });
  });
}
