import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/game_colors.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../services/sound_service.dart';
import '../widgets/game_board.dart';
import '../widgets/game_result_overlay.dart';
import '../widgets/rules_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _rulesShownThisSession = false;

  @override
  void initState() {
    super.initState();
    // soundEnabled를 SharedPreferences 에서 로드
    ref.read(soundProvider).init();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowRules());
  }

  void _maybeShowRules() {
    if (_rulesShownThisSession) return;
    ref.read(firstLaunchProvider.future).then((isFirst) {
      if (isFirst && mounted) {
        _rulesShownThisSession = true;
        _showRules(markSeen: true);
      }
    });
  }

  void _showRules({bool markSeen = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const RulesOverlay(),
    ).then((_) {
      if (markSeen) markRulesSeen();
    });
  }

  String _phaseLabel(GamePhase phase) => switch (phase) {
        GamePhase.p1Turn => 'P1 YOUR TURN',
        GamePhase.p2Turn => 'P2 YOUR TURN',
        GamePhase.animating => 'Animating…',
        GamePhase.gameOver => 'Game Over',
        GamePhase.init => 'Loading…',
      };

  Color _phaseColor(GamePhase phase) => switch (phase) {
        GamePhase.p1Turn => GameColors.p1Color,
        GamePhase.p2Turn => GameColors.p2Color,
        _ => Colors.white54,
      };

  @override
  Widget build(BuildContext context) {
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
                  color: GameColors.p1Color,
                ),
                _TurnPill(
                  label: _phaseLabel(state.phase),
                  color: _phaseColor(state.phase),
                ),
                _ScoreChip(
                  label: 'P2',
                  score: state.scores[1],
                  color: GameColors.p2Color,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white70),
            tooltip: 'Rules',
            onPressed: () => _showRules(),
          ),
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
      bottomNavigationBar: const _LegendBar(),
    );
  }
}

class _TurnPill extends StatelessWidget {
  final String label;
  final Color color;

  const _TurnPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
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
  const _LegendBar();

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
