# Changelog

All notable changes to Magnet Clash will be documented in this file.

## [1.0.1+2] - 2026-03-17

### Added
- Engine unit test suite: 9 tests covering `distanceBetween`, `computeAbsorptions` (weak/strong/same-group/out-of-range), `computeRepelPositions` (clamp), `computeChainAbsorptions` (secondary + dedup), `checkWinCondition`
- `GameState.noMoveWarning` field to signal when a player's turn was consumed with no valid move
- Red flash overlay on `GameBoard` when `noMoveWarning` fires (400 ms fade-out)
- `TODOS.md` tracking deferred work (color DRY, auto-skip V2, end-game stats)

### Fixed
- Turn deadlock: tapping an absorb/repel magnet with no valid targets now consumes the turn and passes to the opponent instead of silently doing nothing
- `_handleAbsorb` `copyWith` now explicitly resets `noMoveWarning: false` so the animating state never carries a stale warning flag

### Removed
- `lib/engine/group_detector.dart` (dead code — never imported after MVP refactor)

## [1.0.0+1] - 2026-03-17

### Added
- Initial MVP: two-player magnet board game with absorb, repel, and chain mechanics
