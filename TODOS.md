# TODOS — Magnet Clash

Eng Review 이후 defer된 항목들.

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

---

## TODO #4 — 배경음악 (BGM) (P3 / Effort: M)

루프 배경음악 추가. SoundService에 `playBgm()` / `stopBgm()` 메서드 구현.
`assets/sounds/bgm.mp3` 파일 추가 필요.

AudioPlayer의 `setReleaseMode(ReleaseMode.loop)` 사용.

---

## TODO #5 — 체인 반응 스크린 셰이크 (P3 / Effort: XS)

chain 흡수 완료 시 화면 전체를 짧게 흔드는 효과.
`_onStatus(completed)` 에서 chain 감지 시 Transform.translate + AnimationController(50ms)로 구현 가능.
