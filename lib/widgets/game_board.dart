import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_state.dart';
import '../providers/game_provider.dart';
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
  Map<String, Offset> _animOffsets = {};
  Map<String, Offset> _startOffsets = {};
  Offset? _targetOffset;
  Size _boardSize = Size.zero;

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
      setState(() => _animOffsets = {});
      ref.read(gameProvider.notifier).onAnimationComplete();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..removeStatusListener(_onStatus)
      ..dispose();
    _flashController.dispose();
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
      if (next.noMoveWarning && prev?.noMoveWarning != true) {
        _flashController.forward(from: 0);
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
            Container(
              color: const Color(0xFF1A1A2E),
              child: CustomPaint(
                painter: MagnetPainter(
                  gameState: state,
                  animationOffsets: _animOffsets,
                ),
                size: _boardSize,
              ),
            ),
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
          ],
        ),
      );
    });
  }
}
