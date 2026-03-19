import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/game_colors.dart';
import '../models/game_state.dart';
import '../models/magnet_type.dart';
import '../models/random_event.dart';
import '../providers/game_provider.dart';
import '../services/sound_service.dart';
import 'magnet_painter.dart';

class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key});

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _flashController;
  late AnimationController _pulseController;
  late AnimationController _invalidTapCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _stormCtrl;
  late AnimationController _eventCtrl;
  RandomEvent _currentEvent = RandomEvent.none;

  Map<String, Offset> _animOffsets = {};
  Map<String, Offset> _startOffsets = {};
  Offset? _targetOffset;
  Size _boardSize = Size.zero;
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatus);

    _flashController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _invalidTapCtrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _particleCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _stormCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _eventCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // SharedPreferences 에서 soundEnabled 로드
    ref.read(soundProvider).init();
  }

  void _onTick() {
    if (_startOffsets.isEmpty || _targetOffset == null) return;
    setState(() {
      _animOffsets = {
        for (final e in _startOffsets.entries)
          e.key: Offset.lerp(e.value, _targetOffset!, _controller.value)!,
      };
    });
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      // 흡수 완료 — 파티클 버스트 + SFX (onAnimationComplete 호출 전에 읽어야 함)
      final state = ref.read(gameProvider);
      final selectedId = state.selectedMagnetId;
      final selected =
          state.magnets.where((m) => m.id == selectedId).firstOrNull;

      _spawnParticles(selected?.ownerId ?? 0);

      if (selected?.type == MagnetType.chain) {
        ref.read(soundProvider).playChain();
      } else {
        ref.read(soundProvider).playAbsorb();
      }

      setState(() => _animOffsets = {});
      ref.read(gameProvider.notifier).onAnimationComplete();
    }
  }

  void _spawnParticles(int ownerId) {
    final target = _targetOffset;
    if (target == null) return;

    final rng = Random();
    final color = GameColors.ownerColor(ownerId);
    final count = (_startOffsets.length * 8).clamp(8, 48);

    final newParticles = <Particle>[];
    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 20.0 + rng.nextDouble() * 30.0;
      newParticles.add(Particle(
        origin: target,
        velocity: Offset(cos(angle), sin(angle)) * speed,
        color: color,
      ));
    }

    setState(() => _particles = newParticles);
    _particleCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..removeStatusListener(_onStatus)
      ..dispose();
    _flashController.dispose();
    _pulseController.dispose();
    _invalidTapCtrl.dispose();
    _particleCtrl.dispose();
    _stormCtrl.dispose();
    _eventCtrl.dispose();
    super.dispose();
  }

  void _startAbsorption(GameState state, List<String> absorbingIds) {
    if (_boardSize == Size.zero) {
      ref.read(gameProvider.notifier).onAnimationComplete();
      return;
    }

    final selected =
        state.magnets.firstWhere((m) => m.id == state.selectedMagnetId);
    _targetOffset =
        Offset(selected.x * _boardSize.width, selected.y * _boardSize.height);

    _startOffsets = {};
    for (final id in absorbingIds) {
      final m = state.magnets.firstWhere((m) => m.id == id);
      _startOffsets[id] =
          Offset(m.x * _boardSize.width, m.y * _boardSize.height);
    }

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameState>(gameProvider, (prev, next) {
      // 이동불가 경고
      if (next.noMoveWarning && prev?.noMoveWarning != true) {
        _flashController.forward(from: 0);
        ref.read(soundProvider).playNoMove();
      }

      // 자기 폭풍 발동
      if (next.magnetStormTrigger && prev?.magnetStormTrigger != true) {
        _stormCtrl.forward(from: 0);
        ref.read(soundProvider).playMagneticStorm();
        HapticFeedback.heavyImpact();
      }

      // 잘못된 탭
      if (next.invalidTap && prev?.invalidTap != true) {
        _invalidTapCtrl.forward(from: 0).then((_) {
          if (mounted) ref.read(gameProvider.notifier).clearInvalidTap();
        });
        ref.read(soundProvider).playInvalidTap();
      }

      // 게임 오버
      if (next.phase == GamePhase.gameOver &&
          prev?.phase != GamePhase.gameOver) {
        _pulseController.stop();
        ref.read(soundProvider).playWin();
      }

      // 게임 리셋 (gameOver → p1Turn)
      if (next.phase == GamePhase.p1Turn &&
          prev?.phase == GamePhase.gameOver) {
        _pulseController.repeat();
        setState(() => _particles = []);
        ref.read(soundProvider).playGameStart();
      }

      // 랜덤 이벤트 발동
      if (next.activeEvent != RandomEvent.none &&
          prev?.activeEvent != next.activeEvent) {
        _currentEvent = next.activeEvent;
        _eventCtrl.forward(from: 0);
        HapticFeedback.mediumImpact();
      }

      // 반발 SFX: turn→turn (또는 turn→gameOver) 전환 시 noMoveWarning/magnetStormTrigger 없이
      // animating을 거치지 않는 직접 전환 = repel 액션
      if (prev != null &&
          (prev.phase == GamePhase.p1Turn ||
              prev.phase == GamePhase.p2Turn) &&
          (next.phase == GamePhase.p1Turn ||
              next.phase == GamePhase.p2Turn ||
              next.phase == GamePhase.gameOver) &&
          !next.noMoveWarning &&
          !next.magnetStormTrigger) {
        ref.read(soundProvider).playRepel();
      }

      if (prev?.phase == GamePhase.gameOver &&
          next.phase != GamePhase.gameOver) {
        // resetGame() 후 gameOver → non-gameOver 시 pulse 재시작
        _pulseController.repeat();
      }

      if (prev?.phase == next.phase) return;
      if (next.phase != GamePhase.animating) return;

      final ids = next.absorbingIds;
      if (ids != null && ids.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startAbsorption(next, ids);
        });
      } else {
        // animating 진입했지만 흡수 없음 → 즉시 완료
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(gameProvider.notifier).onAnimationComplete();
        });
      }
    });

    final state = ref.watch(gameProvider);

    return LayoutBuilder(builder: (context, constraints) {
      _boardSize = Size(constraints.maxWidth, constraints.maxHeight);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          final x = details.localPosition.dx / _boardSize.width;
          final y = details.localPosition.dy / _boardSize.height;
          ref.read(gameProvider.notifier).onBoardTap(x, y);
        },
        child: Stack(
          children: [
            AnimatedBuilder(
              animation:
                  Listenable.merge([_pulseController, _particleCtrl]),
              builder: (context, _) => Container(
                color: const Color(0xFF1A1A2E),
                child: CustomPaint(
                  painter: MagnetPainter(
                    gameState: state,
                    animationOffsets: _animOffsets,
                    pulseValue: _pulseController.value,
                    particles: _particles,
                    particleProgress: _particleCtrl.value,
                  ),
                  size: _boardSize,
                ),
              ),
            ),
            // noMoveWarning — 빨간 플래시
            AnimatedBuilder(
              animation: _flashController,
              builder: (context, _) {
                final opacity =
                    (1.0 - _flashController.value).clamp(0.0, 1.0) *
                        _flashController.value *
                        4.0 *
                        0.35;
                if (opacity <= 0) return const SizedBox.shrink();
                return IgnorePointer(
                  child: Container(
                    color: Colors.red.withValues(alpha: opacity),
                  ),
                );
              },
            ),
            // invalidTap — 오렌지 플래시
            AnimatedBuilder(
              animation: _invalidTapCtrl,
              builder: (context, child) {
                final opacity = (1.0 - _invalidTapCtrl.value) *
                    _invalidTapCtrl.value *
                    4.0 *
                    0.25;
                if (opacity <= 0) return const SizedBox.shrink();
                return IgnorePointer(
                  child: Container(
                    color: Colors.orange.withValues(alpha: opacity),
                  ),
                );
              },
            ),
            // magnetStorm — 노란 플래시
            AnimatedBuilder(
              animation: _stormCtrl,
              builder: (context, _) {
                final v = _stormCtrl.value;
                final opacity = (1.0 - v) * v * 4.0 * 0.5;
                if (opacity <= 0) return const SizedBox.shrink();
                return IgnorePointer(
                  child: Container(
                    color: Colors.yellow.withValues(alpha: opacity),
                  ),
                );
              },
            ),
            // 랜덤 이벤트 — 색상 플래시
            AnimatedBuilder(
              animation: _eventCtrl,
              builder: (context, _) {
                final v = _eventCtrl.value;
                final opacity = (1.0 - v) * v * 4.0 * 0.45;
                if (opacity <= 0) return const SizedBox.shrink();
                final color = switch (_currentEvent) {
                  RandomEvent.polarReversal => Colors.blue,
                  RandomEvent.typeShift => Colors.purple,
                  RandomEvent.bonusSummon => Colors.green,
                  _ => Colors.transparent,
                };
                return IgnorePointer(
                  child: Container(color: color.withValues(alpha: opacity)),
                );
              },
            ),
            // 랜덤 이벤트 — 이름 배너
            AnimatedBuilder(
              animation: _eventCtrl,
              builder: (context, _) {
                final v = _eventCtrl.value;
                final opacity = v < 0.5 ? v * 2 : (1.0 - v) * 2;
                if (opacity <= 0.01) return const SizedBox.shrink();
                return Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            _currentEvent.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
