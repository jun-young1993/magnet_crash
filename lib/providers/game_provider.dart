import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../engine/game_engine.dart';
import '../engine/physics.dart';
import '../models/game_state.dart';
import '../models/magnet.dart';
import '../models/magnet_type.dart';
import '../models/random_event.dart';

final firstLaunchProvider = FutureProvider<bool>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('rules_seen') ?? false);
  } catch (_) {
    return true;
  }
});

Future<void> markRulesSeen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rules_seen', true);
  } catch (_) {}
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier()..initGame();
});

class GameNotifier extends StateNotifier<GameState> {
  static const _p1Count = 4;
  static const _p2Count = 4;
  static const _neutralCount = 12;
  static const _stalemateThreshold = 6; // 연속 6턴 노무브 시 자기 폭풍 발동
  static const _eventInterval = 6;    // 6번 성공 액션마다 이벤트
  static const _bonusSummonCount = 3; // 소환 자석 수

  final _random = Random();
  final _engine = GameEngine();

  GameNotifier()
      : super(const GameState(
          magnets: [],
          phase: GamePhase.init,
          scores: [0, 0],
          turnCount: 0,
        ));

  void initGame() {
    final magnets = <Magnet>[];

    // P1 magnets (왼쪽 절반)
    for (int i = 0; i < _p1Count; i++) {
      magnets.add(Magnet(
        id: 'p1_$i',
        x: _random.nextDouble() * 0.35 + 0.05,
        y: _random.nextDouble() * 0.80 + 0.10,
        type: _randomType(),
        groupId: 0,
        ownerId: 0,
      ));
    }

    // P2 magnets (오른쪽 절반)
    for (int i = 0; i < _p2Count; i++) {
      magnets.add(Magnet(
        id: 'p2_$i',
        x: _random.nextDouble() * 0.35 + 0.60,
        y: _random.nextDouble() * 0.80 + 0.10,
        type: _randomType(),
        groupId: 1,
        ownerId: 1,
      ));
    }

    // 중립 magnets (각자 독립 그룹)
    for (int i = 0; i < _neutralCount; i++) {
      magnets.add(Magnet(
        id: 'n_$i',
        x: _random.nextDouble() * 0.90 + 0.05,
        y: _random.nextDouble() * 0.90 + 0.05,
        type: _randomType(),
        groupId: i + 2,
        ownerId: -1,
      ));
    }

    state = GameState(
      magnets: magnets,
      phase: GamePhase.p1Turn,
      scores: [0, 0],
      turnCount: 0,
    );
  }

  MagnetType _randomType() {
    // repel과 chain은 낮은 확률로 등장
    const weights = [40, 30, 15, 15]; // weak, strong, repel, chain
    final total = weights.reduce((a, b) => a + b);
    int roll = _random.nextInt(total);
    for (int i = 0; i < MagnetType.values.length; i++) {
      roll -= weights[i];
      if (roll < 0) return MagnetType.values[i];
    }
    return MagnetType.weak;
  }

  void onBoardTap(double x, double y) {
    if (state.phase == GamePhase.animating ||
        state.phase == GamePhase.gameOver ||
        state.phase == GamePhase.init) {
      return;
    }

    final currentOwnerId = state.phase == GamePhase.p1Turn ? 0 : 1;
    final nearest = findNearestMagnet(x, y, state.magnets);
    if (nearest == null) return;
    if (nearest.ownerId != currentOwnerId) {
      HapticFeedback.selectionClick();
      state = state.copyWith(invalidTap: true);
      return;
    }

    if (nearest.type == MagnetType.repel) {
      _handleRepel(nearest);
    } else {
      _handleAbsorb(nearest);
    }
  }

  void _handleAbsorb(Magnet selected) {
    final absorptions = computeAbsorptions(selected, state.magnets);
    if (absorptions.isEmpty) {
      // 흡수 대상 없음 → 턴 강제 소비 + 경고 표시
      _consumeTurnWithWarning(selected.ownerId);
      return;
    }

    HapticFeedback.mediumImpact();

    state = state.copyWith(
      phase: GamePhase.animating,
      selectedMagnetId: selected.id,
      absorbingIds: absorptions.map((m) => m.id).toList(),
      noMoveWarning: false,
    );
  }

  void _handleRepel(Magnet repeller) {
    final repelled = computeRepelPositions(repeller, state.magnets);
    if (repelled.isEmpty) {
      // 반발 대상 없음 → 턴 강제 소비 + 경고 표시
      _consumeTurnWithWarning(repeller.ownerId);
      return;
    }

    HapticFeedback.lightImpact();

    final updatedMagnets = state.magnets.map((m) {
      return repelled.firstWhere((r) => r.id == m.id, orElse: () => m);
    }).toList();

    _advanceTurn(updatedMagnets, 0, selected: repeller);
  }

  void _consumeTurnWithWarning(int ownerId) {
    final newStalemateTurns = state.stalemateTurns + 1;
    final nextPhase = _engine.nextPhase(
        ownerId == 0 ? GamePhase.p1Turn : GamePhase.p2Turn);

    if (newStalemateTurns >= _stalemateThreshold) {
      _triggerMagneticStorm(nextPhase);
      return;
    }

    state = GameState(
      magnets: state.magnets,
      phase: nextPhase,
      scores: List<int>.from(state.scores),
      turnCount: state.turnCount + 1,
      stalemateTurns: newStalemateTurns,
      noMoveWarning: true,
    );
  }

  void _triggerMagneticStorm(GamePhase nextPhase) {
    final neutrals = state.magnets.where((m) => m.ownerId == -1).toList();
    debugPrint('[Turn ${state.turnCount + 1}] MagneticStorm triggered. '
        'Neutrals: ${neutrals.length}, stalemateTurns: ${state.stalemateTurns}');

    if (neutrals.isEmpty) {
      // 처리 불가 케이스 → 점수로 게임 종료
      state = GameState(
        magnets: state.magnets,
        phase: GamePhase.gameOver,
        scores: List<int>.from(state.scores),
        turnCount: state.turnCount + 1,
        stalemateTurns: 0,
      );
      return;
    }

    // 중립 자석들을 중앙(0.5, 0.5) 방향으로 60% 이동
    final newMagnets = state.magnets.map((m) {
      if (m.ownerId != -1) return m;
      final newX = (m.x + (0.5 - m.x) * 0.6).clamp(0.05, 0.95);
      final newY = (m.y + (0.5 - m.y) * 0.6).clamp(0.05, 0.95);
      return m.copyWith(x: newX, y: newY);
    }).toList();

    state = GameState(
      magnets: newMagnets,
      phase: nextPhase,
      scores: List<int>.from(state.scores),
      turnCount: state.turnCount + 1,
      stalemateTurns: 0,
      magnetStormTrigger: true,
    );
  }

  /// 애니메이션 완료 후 호출 — 흡수 처리 및 턴 전환
  void onAnimationComplete() {
    if (state.phase != GamePhase.animating) return;

    final absorbingIds = state.absorbingIds ?? [];
    if (absorbingIds.isEmpty) {
      // 흡수 없이 animating 진입한 경우 (방어 코드)
      _advanceTurn(state.magnets, 0);
      return;
    }

    final selected = state.magnets.firstWhere(
      (m) => m.id == state.selectedMagnetId,
      orElse: () => state.magnets.first,
    );

    final primaryAbsorbed =
        state.magnets.where((m) => absorbingIds.contains(m.id)).toList();
    int score = primaryAbsorbed.length;

    // chain 반응: 2차 흡수
    final Set<String> allAbsorbIds = {...absorbingIds};
    if (selected.type == MagnetType.chain) {
      final remaining = state.magnets
          .where((m) => !absorbingIds.contains(m.id) && m.id != selected.id)
          .toList();
      final chainAbsorbed =
          computeChainAbsorptions(primaryAbsorbed, remaining);
      for (final m in chainAbsorbed) {
        allAbsorbIds.add(m.id);
      }
      score += chainAbsorbed.length;
    }

    final newMagnets =
        state.magnets.where((m) => !allAbsorbIds.contains(m.id)).toList();

    final newScores = List<int>.from(state.scores);
    newScores[selected.ownerId] += score;

    debugPrint(
        '[Turn ${state.turnCount + 1}] P${selected.ownerId + 1} absorbed $score magnets. '
        'Remaining: ${newMagnets.length}. Scores: $newScores');

    _advanceTurn(newMagnets, score, scores: newScores, selected: selected);
  }

  void _advanceTurn(
    List<Magnet> newMagnets,
    int score, {
    List<int>? scores,
    Magnet? selected,
  }) {
    final newScores = scores ?? List<int>.from(state.scores);
    final isGameOver = _engine.checkWinCondition(newMagnets);
    final ownerId =
        selected?.ownerId ?? (state.phase == GamePhase.p1Turn ? 0 : 1);
    final nextPhase = isGameOver
        ? GamePhase.gameOver
        : _engine.nextPhase(
            ownerId == 0 ? GamePhase.p1Turn : GamePhase.p2Turn);

    final newTurnCount = state.turnCount + 1;
    List<Magnet> finalMagnets = newMagnets;
    RandomEvent event = RandomEvent.none;

    if (!isGameOver && newTurnCount % _eventInterval == 0) {
      (finalMagnets, event) = _applyRandomEvent(newMagnets);
    }

    state = GameState(
      magnets: finalMagnets,
      phase: nextPhase,
      scores: newScores,
      turnCount: newTurnCount,
      stalemateTurns: 0,
      noMoveWarning: false,
      activeEvent: event,
    );
  }

  (List<Magnet>, RandomEvent) _applyRandomEvent(List<Magnet> magnets) {
    const events = [
      RandomEvent.polarReversal,
      RandomEvent.typeShift,
      RandomEvent.bonusSummon,
    ];
    final event = events[_random.nextInt(events.length)];
    return switch (event) {
      RandomEvent.polarReversal => (_applyPolarReversal(magnets), event),
      RandomEvent.typeShift => (_applyTypeShift(magnets), event),
      RandomEvent.bonusSummon => (_applyBonusSummon(magnets), event),
      RandomEvent.none => throw AssertionError('none은 events 리스트에 없음 — 도달 불가'),
    };
  }

  List<Magnet> _applyPolarReversal(List<Magnet> magnets) {
    return magnets.map((m) => switch (m.type) {
          MagnetType.repel => m.copyWith(type: MagnetType.weak),
          MagnetType.weak => m.copyWith(type: MagnetType.repel),
          _ => m,
        }).toList();
  }

  List<Magnet> _applyTypeShift(List<Magnet> magnets) {
    return magnets.map((m) {
      if (m.ownerId != -1) return m; // 플레이어 자석 유지
      return m.copyWith(type: _randomType());
    }).toList();
  }

  List<Magnet> _applyBonusSummon(List<Magnet> magnets) {
    if (magnets.isEmpty) return magnets;
    final maxGroupId = magnets.map((m) => m.groupId).reduce(max);
    final newMagnets = List<Magnet>.from(magnets);
    for (int i = 0; i < _bonusSummonCount; i++) {
      newMagnets.add(Magnet(
        id: 'bonus_${state.turnCount}_$i',
        x: _random.nextDouble() * 0.6 + 0.2, // 0.2~0.8 중앙 영역
        y: _random.nextDouble() * 0.6 + 0.2,
        type: _randomType(),
        groupId: maxGroupId + 1 + i,
        ownerId: -1,
      ));
    }
    return newMagnets;
  }

  void clearInvalidTap() {
    if (state.invalidTap) state = state.copyWith(invalidTap: false);
  }

  void resetGame() => initGame();
}
