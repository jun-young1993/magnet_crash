import 'magnet.dart';
import 'random_event.dart';

enum GamePhase { init, p1Turn, p2Turn, animating, gameOver }

class GameState {
  final List<Magnet> magnets;
  final GamePhase phase;
  final List<int> scores;
  final int turnCount;
  final String? selectedMagnetId;
  final List<String>? absorbingIds;
  final bool noMoveWarning;
  final bool invalidTap;
  final int stalemateTurns;
  final bool magnetStormTrigger;
  final RandomEvent activeEvent;

  const GameState({
    required this.magnets,
    required this.phase,
    required this.scores,
    required this.turnCount,
    this.selectedMagnetId,
    this.absorbingIds,
    this.noMoveWarning = false,
    this.invalidTap = false,
    this.stalemateTurns = 0,
    this.magnetStormTrigger = false,
    this.activeEvent = RandomEvent.none,
  });

  static const _unset = Object();

  GameState copyWith({
    List<Magnet>? magnets,
    GamePhase? phase,
    List<int>? scores,
    int? turnCount,
    Object? selectedMagnetId = _unset,
    Object? absorbingIds = _unset,
    bool? noMoveWarning,
    bool? invalidTap,
    int? stalemateTurns,
    bool? magnetStormTrigger,
    RandomEvent? activeEvent,
  }) {
    return GameState(
      magnets: magnets ?? this.magnets,
      phase: phase ?? this.phase,
      scores: scores ?? this.scores,
      turnCount: turnCount ?? this.turnCount,
      selectedMagnetId: identical(selectedMagnetId, _unset)
          ? this.selectedMagnetId
          : selectedMagnetId as String?,
      absorbingIds: identical(absorbingIds, _unset)
          ? this.absorbingIds
          : absorbingIds as List<String>?,
      noMoveWarning: noMoveWarning ?? this.noMoveWarning,
      invalidTap: invalidTap ?? this.invalidTap,
      stalemateTurns: stalemateTurns ?? this.stalemateTurns,
      magnetStormTrigger: magnetStormTrigger ?? this.magnetStormTrigger,
      activeEvent: activeEvent ?? this.activeEvent,
    );
  }
}
