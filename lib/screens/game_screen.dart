import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/game_result_overlay.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  String _phaseLabel(GamePhase phase) => switch (phase) {
        GamePhase.p1Turn => "Player 1's Turn",
        GamePhase.p2Turn => "Player 2's Turn",
        GamePhase.animating => 'Animating…',
        GamePhase.gameOver => 'Game Over',
        GamePhase.init => 'Loading…',
      };

  Color _phaseColor(GamePhase phase) => switch (phase) {
        GamePhase.p1Turn => const Color(0xFF4FC3F7),
        GamePhase.p2Turn => const Color(0xFFEF9A9A),
        _ => Colors.white54,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        title: const Text(
          'Magnet Clash',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ScoreChip(
                    label: 'P1',
                    score: state.scores[0],
                    color: const Color(0xFF4FC3F7)),
                Text(
                  _phaseLabel(state.phase),
                  style: TextStyle(
                    color: _phaseColor(state.phase),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _ScoreChip(
                    label: 'P2',
                    score: state.scores[1],
                    color: const Color(0xFFEF9A9A)),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'New Game',
            onPressed: () => ref.read(gameProvider.notifier).resetGame(),
          ),
        ],
      ),
      body: Stack(
        children: [
          const GameBoard(),
          if (state.phase == GamePhase.gameOver) const GameResultOverlay(),
        ],
      ),
      bottomNavigationBar: _LegendBar(),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreChip(
      {required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $score',
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class _LegendBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      ('W', Color(0xFFE0E0E0), 'Weak'),
      ('S', Color(0xFFFFD54F), 'Strong'),
      ('R', Color(0xFF69F0AE), 'Repel'),
      ('C', Color(0xFFCE93D8), 'Chain'),
    ];
    return Container(
      height: 36,
      color: const Color(0xFF16213E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final (label, color, name) in items)
            Row(children: [
              CircleAvatar(radius: 8, backgroundColor: color),
              const SizedBox(width: 4),
              Text('$label=$name',
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
        ],
      ),
    );
  }
}
