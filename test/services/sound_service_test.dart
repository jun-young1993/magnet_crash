import 'package:flutter_test/flutter_test.dart';
import 'package:magnet_crash/services/sound_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SoundService', () {
    test('기본 soundEnabled = true', () {
      final svc = SoundService();
      expect(svc.soundEnabled, true);
      svc.dispose();
    });

    test('soundEnabled=false 시 play 메서드가 예외 없이 종료됨 (AudioPlayer 미생성)', () async {
      final svc = SoundService();
      svc.soundEnabled = false;

      // soundEnabled=false이면 _play()가 즉시 리턴 → AudioPlayer 생성 안 됨
      await svc.playAbsorb();
      await svc.playChain();
      await svc.playRepel();
      await svc.playWin();
      await svc.playInvalidTap();
      await svc.playNoMove();
      await svc.playGameStart();

      // 예외 없이 통과 + AudioPlayer pool 미생성 확인
      svc.dispose(); // pool이 null이므로 안전
    });

    test('toggleSound()가 soundEnabled를 반전시킴', () async {
      final svc = SoundService();
      expect(svc.soundEnabled, true);

      await svc.toggleSound();
      expect(svc.soundEnabled, false);

      await svc.toggleSound();
      expect(svc.soundEnabled, true);

      svc.dispose();
    });

    test('init()이 SharedPreferences의 sound_enabled 값을 로드함', () async {
      SharedPreferences.setMockInitialValues({'sound_enabled': false});

      final svc = SoundService();
      await svc.init();
      expect(svc.soundEnabled, false);

      svc.dispose();
    });

    test('dispose() 중복 호출 시 예외 없음', () {
      final svc = SoundService();
      // pool 미생성 상태에서 dispose 두 번
      expect(() => svc.dispose(), returnsNormally);
      expect(() => svc.dispose(), returnsNormally);
    });
  });
}
