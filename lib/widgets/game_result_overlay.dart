import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/game_engine.dart';
import '../providers/game_provider.dart';

class GameResultOverlay extends ConsumerWidget {
  const GameResultOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final winner = GameEngine().winnerOwnerId(state.magnets, state.scores);

    final (label, color) = switch (winner) {
      0 => ('Player 1 Wins!', const Color(0xFF4FC3F7)),
      1 => ('Player 2 Wins!', const Color(0xFFEF9A9A)),
      _ => ('Draw!', Colors.amber),
    };

    return Container(
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
              style: const TextStyle(color: Colors.white70, fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.turnCount} turns',
              style: const TextStyle(color: Colors.white38, fontSize: 16),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: () => ref.read(gameProvider.notifier).resetGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Play Again',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
