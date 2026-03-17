# TODOS — Magnet Clash

Eng Review 이후 defer된 항목들.

---

## TODO #1 — 색상 상수 DRY 추출 (P3 / Effort: XS)

`lib/constants/game_colors.dart` 생성, 3개 파일의 중복 색상 매핑 통합.

현재 `magnet_painter.dart`, `game_result_overlay.dart`, `game_screen.dart`에 동일한 플레이어/타입 색상 매핑 코드가 중복됨.

---

## TODO #2 — 자동 턴 스킵 V2 (P2 / Effort: S)

턴 시작 전 현재 플레이어가 아무 이동도 불가능할 때 자동 스킵 + UI 하이라이트.

- 현재 PR: 탭 시 턴 강제 소비로 데드락 방지 (noMoveWarning flash).
- V2: 사전 검사로 탭 없이 자동 스킵 → 더 나은 UX.

**Depends on:** TODO #2 이전 단계(현 PR) 완료 후.

---

## TODO #3 — 게임 종료 통계 화면 (P2 / Effort: M)

게임 오버레이에 chain 반응 횟수, 최대 흡수 깊이 표시.

`GameState`에 `chainReactionCount`, `maxAbsorptionDepth` 필드 추가 필요.
