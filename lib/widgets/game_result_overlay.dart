import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/game_colors.dart';
import '../engine/game_engine.dart';
import '../providers/game_provider.dart';

class GameResultOverlay extends ConsumerStatefulWidget {
  const GameResultOverlay({super.key});

  @override
  ConsumerState<GameResultOverlay> createState() => _GameResultOverlayState();
}

class _GameResultOverlayState extends ConsumerState<GameResultOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final winner = GameEngine().winnerOwnerId(state.magnets, state.scores);

    final (label, color) = switch (winner) {
      0 => ('Player 1 Wins!', GameColors.p1Color),
      1 => ('Player 2 Wins!', GameColors.p2Color),
      _ => ('Draw!', Colors.amber),
    };

    return Stack(
      children: [
        // 오버레이 배경 + 텍스트
        Container(
          color: Colors.black.withValues(alpha: 0.82),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'P1: ${state.scores[0]}  |  P2: ${state.scores[1]}',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.turnCount} turns',
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 16),
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(gameProvider.notifier).resetGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Confetti バースト (화면 상단 중앙)
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: [GameColors.p1Color, GameColors.p2Color, Colors.white],
            numberOfParticles: 30,
            gravity: 0.3,
          ),
        ),
      ],
    );
  }
}
