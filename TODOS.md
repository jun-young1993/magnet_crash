# TODOS — Magnet Clash

## 게임 로직 (Game Engine / Provider)

### TODO #2 — 자동 턴 스킵 V2

**What:** 턴 시작 전 현재 플레이어가 아무 이동도 불가능할 때 자동 스킵 + UI 하이라이트.

**Why:** 현재는 플레이어가 탭해야 턴이 소비되어 UX가 어색함. 사전 검사로 자동 스킵하면 더 자연스러운 흐름.

**Context:** 현재 구현(v1)은 탭 시 턴 강제 소비 + `noMoveWarning` flash로 데드락 방지. V2는 `_computeValidMoves()` 결과가 빈 경우 턴 시작 시 자동 전환.

**Effort:** S
**Priority:** P2
**Depends on:** None

---

### TODO #7 — 자기 폭풍 강제 종료 시 gameOver 사유 표시

**What:** 중립 자석이 없는 상태에서 6턴 연속 노무브 → 조용히 `GamePhase.gameOver` 전환. gameOver 오버레이에 원인 표시.

**Why:** 플레이어 입장에서 "왜 게임이 끝났지?" 의문이 생길 수 있음. 명확한 사유 표시로 UX 개선.

**Context:** `GameState`에 `gameOverReason` 필드 추가 (`enum GameOverReason { normal, magneticStormTrap }`), `GameResultOverlay`에서 reason이 `magneticStormTrap`이면 "자기 폭풍으로 교착!" 메시지 표시.

**Effort:** S
**Priority:** P3
**Depends on:** TODO #3 (게임 종료 통계 화면)과 함께 처리하면 시너지

---

### TODO #8 — 랜덤 이벤트 로직 단위 테스트

**What:** `_applyPolarReversal`, `_applyTypeShift`, `_applyBonusSummon` 단위 테스트.

**Why:** 세 메서드는 순수 함수이므로 단위 테스트가 이상적. 이벤트 gate 조건(`turnCount % 6`, `isGameOver`)도 커버.

**Context:** 커버해야 할 케이스:
1. polarReversal: weak→repel, repel→weak, strong→unchanged, chain→unchanged
2. typeShift: neutral 변경, player(ownerId≠-1) 유지
3. bonusSummon: +3 magnets, groupId 유일성, 좌표 0.2~0.8 범위
4. 이벤트 gate: turnCount % 6 != 0 시 이벤트 없음
5. 이벤트 gate: isGameOver 시 이벤트 없음
6. bonusSummon isEmpty 가드 (빈 리스트 → 그대로 반환)

**Effort:** S
**Priority:** P2
**Depends on:** `flutter test` 인프라 셋업 (현재 테스트 디렉토리 없음)

---

## UI / UX

### TODO #3 — 게임 종료 통계 화면

**What:** 게임 오버레이에 chain 반응 횟수, 최대 흡수 깊이 표시.

**Why:** 플레이어에게 플레이 퀄리티 피드백 제공. 재플레이 동기 부여.

**Context:** `GameState`에 `chainReactionCount`, `maxAbsorptionDepth` 필드 추가. `_engine.checkWinCondition` 흐름에서 누적. `GameResultOverlay`에 표시.

**Effort:** M
**Priority:** P2
**Depends on:** None

---

### TODO #5 — 체인 반응 스크린 셰이크

**What:** chain 흡수 완료 시 화면 전체를 짧게 흔드는 효과.

**Why:** 체인 반응의 임팩트감 강화.

**Context:** `_onStatus(completed)`에서 chain 감지 시 `Transform.translate` + `AnimationController(50ms)`로 구현 가능.

**Effort:** XS
**Priority:** P3
**Depends on:** None

---

## 사운드 (Sound)

### TODO #6 — 자기 폭풍 SFX 파일 추가

**What:** `assets/sounds/magnetic_storm.wav` 파일 추가.

**Why:** 현재 `SoundService.playMagneticStorm()`은 파일이 없으면 조용히 실패하고 `HapticFeedback.heavyImpact()`만 작동. 파일만 추가하면 SFX 자동 재생.

**Context:** 코드 변경 불필요. 사운드 에셋 작업 시 함께 처리 권장.

**Effort:** XS
**Priority:** P2
**Depends on:** 사운드 에셋 작업 일정

---

### TODO #4 — 배경음악 (BGM)

**What:** 루프 배경음악 추가. `SoundService`에 `playBgm()` / `stopBgm()` 메서드 구현.

**Why:** 게임 몰입감 향상.

**Context:** `assets/sounds/bgm.mp3` 파일 추가 필요. `AudioPlayer`의 `setReleaseMode(ReleaseMode.loop)` 사용. SFX 토글과 별개로 BGM 토글도 필요할 수 있음.

**Effort:** M
**Priority:** P3
**Depends on:** None

---

## Completed

(항목 없음)
