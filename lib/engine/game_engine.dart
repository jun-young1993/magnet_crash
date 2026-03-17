import '../models/game_state.dart';
import '../models/magnet.dart';

class GameEngine {
  /// P1 → P2 → P1 순환
  GamePhase nextPhase(GamePhase current) => switch (current) {
        GamePhase.p1Turn => GamePhase.p2Turn,
        GamePhase.p2Turn => GamePhase.p1Turn,
        _ => current,
      };

  /// 2그룹 이하 → 게임 종료
  bool checkWinCondition(List<Magnet> magnets) {
    final groups = magnets.map((m) => m.groupId).toSet();
    return groups.length <= 2;
  }

  /// 승리 플레이어 ownerId 반환 (-1 = 무승부)
  int winnerOwnerId(List<Magnet> magnets, List<int> scores) {
    if (scores[0] > scores[1]) return 0;
    if (scores[1] > scores[0]) return 1;
    return -1;
  }
}
