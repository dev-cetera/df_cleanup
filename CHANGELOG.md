# Changelog

## [1.0.0]

- Released @ 5/2026 (UTC)
- breaking: Full rewrite. New API surface:
  - `DisposeBag` — pure-Dart cleanup collector with LIFO, idempotent `dispose()`.
  - `WillCleanupMixin` — single mixin replacing `WillCancelMixin` / `WillCloseMixin` / `WillDisposeMixin` / `WillStopMixin`. Exposes `willDispose` / `willClose` / `willCancel` / `willStop` (explicit), `willCleanup` (auto-detects), and `addCleanup` (raw callback).
  - `CleanupStateMixin<W>` and `CleanupState<W>` — Flutter `State` integration; calls `cleanup()` in `dispose()`.
- breaking: Removed `ContextStore` / `AssociatedContextStore` (polling singleton — anti-pattern).
- breaking: Removed `AttachableMixin` / `StatefulAttachableMixin` / `StatelessAttachableMixin` / `StatefulWidgetWithAttachable` / `AttachableElementMixin` (build-count heuristic was brittle across rebuilds).
- breaking: Removed `context.willDispose()` and friends extensions (footgun — the example file literally warned against them).
- breaking: Removed `*ListsMixin` (manual init, didn't hook into lifecycle — just instantiate a `DisposeBag` directly).
- breaking: Errors consolidated to `NoCleanupMethodDebugError` and `WillAlreadyRegisteredDebugError`. Surfaced via `assert` rather than unconditional throw — release builds tolerate duplicates by replacing.
- breaking: Dropped runtime dependency on `df_type` (`Waiter` is no longer used). Added dep on `meta`.

## [0.4.8]

- Released @ 6/2025 (UTC)
- Add back readme

## [0.4.7]

- Released @ 6/2025 (UTC)
- Update dependencies

## [0.4.6]

- Released @ 6/2025 (UTC)
- Update dependencies

## [0.4.5]

- Released @ 6/2025 (UTC)
- Update dependencies

## [0.4.3]

- Released @ 6/2025 (UTC)
- chore: Upade dependencies

## [0.4.1]

- Released @ 2/2025 (UTC)
- chore: Update dependencies

## [0.4.0]

- Released @ 2/2025 (UTC)
- breaking: Update dependencies

## [0.3.4]

- Released @ 2/2025 (UTC)
- chore: Update dependencies

## [0.3.3]

- Released @ 2/2025 (UTC)
- chore: Update dependencies

## [0.3.2]

- Released @ 2/2025 (UTC)
- chore: Update dependencies

## [0.3.1]

- Released @ 2/2025 (UTC)
- chore: Update dependencies

## [0.3.0]

- Released @ 2/2025 (UTC)
- breaking: Update dependencies and docs

## [0.2.2]

- Released @ 2/2025 (UTC)
- chore: Update dependencies

## [0.2.1]

- Released @ 2/2025 (UTC)
- chore: Update dependencies

## [0.2.0]

- Released @ 2/2025 (UTC)
- breaking: Remove utils, depend on df_type package, rename mixins from previous release

## [0.1.6]

- Released @ 2/2025 (UTC)
- fix: Fix another bug with mixins

## [0.1.5]

- Released @ 2/2025 (UTC)
- fix: Fix bug with mixins

## [0.1.4]

- Released @ 2/2025 (UTC)
- feat: Add CancelablesMixin, ClosablesMixin, DisposablesMixin and StoppablesMixin

## [0.1.3]

- Released @ 2/2025 (UTC)
- refactor: Update FutureOrController's with an addAll method

## [0.1.2]

- Released @ 2/2025 (UTC)
- refactor: Change FutureOrController's complete method to accept an optional onComplete callback

## [0.1.1]

- Released @ 2/2025 (UTC)
- chore: Fix issues with async behaviour

## [0.1.0]

- Released @ 2/2025 (UTC)
- Initial commit
