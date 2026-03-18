import 'magnet.dart';

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

  const GameState({
    required this.magnets,
    required this.phase,
    required this.scores,
    required this.turnCount,
    this.selectedMagnetId,
    this.absorbingIds,
    this.noMoveWarning = false,
    this.invalidTap = false,
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
    );
  }
}
