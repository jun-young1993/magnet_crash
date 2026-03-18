import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final soundProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(service.dispose);
  return service;
});

class SoundService {
  static const _poolSize = 3;

  // Lazy: AudioPlayers are created only on first _play() call.
  // This prevents platform-channel errors when sound is disabled or in tests.
  List<AudioPlayer>? _pool;
  int _poolIdx = 0;
  bool soundEnabled = true;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      soundEnabled = prefs.getBool('sound_enabled') ?? true;
    } catch (_) {} // 실패 시 기본값 true 유지
  }

  Future<void> toggleSound() async {
    soundEnabled = !soundEnabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', soundEnabled);
    } catch (_) {}
  }

  List<AudioPlayer> _getPool() {
    _pool ??= List.generate(_poolSize, (_) => AudioPlayer());
    return _pool!;
  }

  Future<void> _play(String asset) async {
    if (!soundEnabled) return;
    try {
      final pool = _getPool();
      await pool[_poolIdx++ % _poolSize].play(AssetSource(asset));
    } catch (e) {
      debugPrint('[SoundService] play failed ($asset): $e');
    }
  }

  Future<void> playAbsorb() => _play('sounds/absorb.wav');
  Future<void> playChain() => _play('sounds/chain.wav');
  Future<void> playRepel() => _play('sounds/repel.wav');
  Future<void> playWin() => _play('sounds/win.wav');
  Future<void> playInvalidTap() => _play('sounds/invalid_tap.wav');
  Future<void> playNoMove() => _play('sounds/no_move.wav');
  Future<void> playGameStart() => _play('sounds/game_start.wav');

  void dispose() {
    final pool = _pool;
    if (pool != null) {
      for (final p in pool) {
        p.dispose();
      }
      _pool = null;
    }
  }
}
