# Changelog

All notable changes to Magnet Clash will be documented in this file.

## [1.0.3+4] - 2026-03-19

### Added
- `RandomEvent` enum (`polarReversal`, `typeShift`, `bonusSummon`, `none`) with Korean display labels via `RandomEventDisplay` extension
- `activeEvent`, `stalemateTurns`, `magnetStormTrigger` fields on `GameState`
- Random event system in `GameNotifier`: fires every 6th successful action (`_eventInterval`), picks one of three events
  - `polarReversal`: swaps `weak` ↔ `repel` for all magnets
  - `typeShift`: randomizes type of all neutral magnets
  - `bonusSummon`: spawns 3 new neutral magnets in the 0.2–0.8 center area
- Stalemate detection: 6 consecutive no-move turns trigger a magnetic storm (`_stalemateThreshold`)
  - Magnetic storm moves all neutral magnets 60% toward center (0.5, 0.5)
  - If no neutrals remain, game ends immediately via `GamePhase.gameOver`
- `SoundService.playMagneticStorm()` — plays `sounds/magnetic_storm.wav` (graceful no-op if file absent)
- Event flash overlays on `GameBoard`: yellow flash for magnetic storm, color-coded flash + name banner for random events
- `HapticFeedback.heavyImpact()` on storm, `mediumImpact()` on random event
- TODO #6 (magnetic storm SFX asset), TODO #7 (gameOver reason display), TODO #8 (random event unit tests) added to TODOS.md

### Changed
- `_consumeTurnWithWarning` now tracks `stalemateTurns` and delegates to `_triggerMagneticStorm` at threshold
- Repel SFX guard extended: suppressed when `magnetStormTrigger` is true (avoids double-fire)
- `_advanceTurn` resets `stalemateTurns` to 0 on every successful action
- `_applyBonusSummon` guarded with `isEmpty` check (returns unchanged list for empty input)
- Dead `if (repelled.isEmpty) return` branch removed from repel path

## [1.0.2+3] - 2026-03-18

### Added
- `SoundService` with lazy AudioPlayer pool (size 3) and per-sound SFX methods: absorb, chain, repel, win, invalid_tap, no_move, game_start
- `sound_enabled` preference persisted to SharedPreferences via `toggleSound()` / `init()`
- `GameColors` abstract class (`lib/constants/game_colors.dart`) — centralized player/type color constants used across painter, overlay, and screen
- `invalidTap` field on `GameState` — triggers orange flash overlay and SFX when player taps an opponent or neutral magnet without consuming a turn
- `clearInvalidTap()` on `GameNotifier` — resets flag after animation completes
- Orange flash overlay on `GameBoard` (`_invalidTapCtrl`, 350 ms) for invalid tap feedback
- Particle burst effect on absorption completion (`_particleCtrl`, 600 ms, 8–48 particles scaled by absorbed count)
- Pulse ring animation on current player's magnets (`_pulseController`, 2 s repeat)
- `RulesOverlay` bottom-sheet widget explaining magnet types and game rules
- First-launch detection via `firstLaunchProvider` (SharedPreferences `rules_seen` key) — rules shown automatically on first open
- `audioplayers ^5.2.0` and `confetti ^0.7.0` added to dependencies
- `assets/sounds/` asset bundle declared in pubspec
- Comprehensive test suite: `SoundService` (5 tests), `firstLaunchProvider` (3 tests), `invalidTap` flow (4 tests), widget tests for `RulesOverlay` and particle reset (4 tests)

### Changed
- `MagnetPainter` now renders pulse rings, absorption range previews, particle effects, and subtle grid background
- `GameResultOverlay` refactored to use `GameColors` and adds confetti animation on game over
- `GameBoard` SFX dispatch integrated into `ref.listen` — repel/absorb/chain/win/game_start sounds fire on state transitions
- README updated with SFX replacement guide (file names, events, recommended lengths/format)
- `TODOS.md` updated: TODO #1 (color DRY) marked resolved, TODO #4 (BGM) and TODO #5 (chain screen shake) added as deferred

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
