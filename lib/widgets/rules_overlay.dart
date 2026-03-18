import 'package:flutter/material.dart';

import '../constants/game_colors.dart';
import '../models/magnet_type.dart';

class RulesOverlay extends StatelessWidget {
  const RulesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'How to Play',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          const _RuleRow(
            color: GameColors.p1Color,
            text: 'P1 (Blue) — tap your blue magnets to activate them',
          ),
          const SizedBox(height: 8),
          const _RuleRow(
            color: GameColors.p2Color,
            text: 'P2 (Red) — tap your red magnets to activate them',
          ),
          const SizedBox(height: 8),
          const _RuleRow(
            color: GameColors.neutralColor,
            text: 'Gray = neutral magnets (cannot be tapped, gets absorbed)',
          ),
          const SizedBox(height: 20),
          const Text(
            'Magnet Types',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          _TypeRow(
            label: 'W',
            color: GameColors.typeAccent(MagnetType.weak),
            name: 'Weak',
            desc: 'absorbs nearby magnets in a small radius',
          ),
          const SizedBox(height: 6),
          _TypeRow(
            label: 'S',
            color: GameColors.typeAccent(MagnetType.strong),
            name: 'Strong',
            desc: 'absorbs magnets in a wide radius',
          ),
          const SizedBox(height: 6),
          _TypeRow(
            label: 'R',
            color: GameColors.typeAccent(MagnetType.repel),
            name: 'Repel',
            desc: 'pushes nearby magnets away',
          ),
          const SizedBox(height: 6),
          _TypeRow(
            label: 'C',
            color: GameColors.typeAccent(MagnetType.chain),
            name: 'Chain',
            desc: 'absorbs + triggers chain reactions',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.tips_and_updates_outlined,
                    color: Colors.amber, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pulsing magnets are yours to tap this turn!',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: GameColors.p1Color,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Got it!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final Color color;
  final String text;

  const _RuleRow({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  final String label;
  final Color color;
  final String name;
  final String desc;

  const _TypeRow({
    required this.label,
    required this.color,
    required this.name,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$name — ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            desc,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
