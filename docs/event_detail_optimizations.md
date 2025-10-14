# Event Detail Module Optimization Ideas

This document collects potential refactorings and enhancements for the `features/events/presentation/pages/detail` module. Items are grouped by category and ordered roughly by impact.

## Rendering & Performance
- **Defer expensive hero layout work:** `EventDetailBody` eagerly builds the `Hero`/`ClipRRect` tree even for events without media. Gate the media header with an early return to avoid running the `AnimatedBuilder` and `Hero` when `_hasMedia` is false.
- **Use `AnimatedSwitcher` instead of manual opacity math:** The gradient overlay currently recalculates opacity via `_headerStretchController`. An `AnimatedSwitcher` with predefined fade curves can simplify the code and ensure repaint bounds stay small.
- **Cache media counts:** `_mediaCount` recomputes filtered lists on every access. Cache the value during `initState`/`didUpdateWidget` to reduce allocations in scroll listeners and hero transitions.
- **Prefer `SliverList.builder`:** The detail body uses `SliverChildListDelegate` with static spacing widgets. Switching to `SliverList` with a builder and extracting spacing into padding reduces widget churn and improves readability.

## State & Logic
- **Move analytics & haptics into a controller:** `_handleScroll` mixes gesture, navigation, analytics, and haptic responsibilities. Creating an `EventDetailInteractionController` would keep the widget lean and simplify testing.
- **Promote callbacks into a view-model:** The widget constructor accepts many callbacks and data fields. Wrapping them inside a `EventDetailViewModel` object allows easier additions and keeps call sites cleaner.
- **Debounce fullscreen navigation:** `_openFullScreen` relies on `_navigatingToFullScreen` flags. Replace with `Navigator` route guard or `throttle` helper to prevent double pushes across rebuilds.

## Accessibility & UX
- **Add semantics for media carousel pagination:** Expose current image index to screen readers via `Semantics(label: '${index + 1} of $_mediaCount')` to improve accessibility.
- **Support keyboard shortcuts:** Map arrow keys to page controller actions for desktop/web builds.
- **Persist follow state optimistically:** Hook the `onToggleFollow` to immediate UI updates and rollback on failure to feel responsive.

## Code Organization
- **Extract shared media header widget:** Multiple pages likely repeat the media hero logic (`EventMediaCarousel`, fullscreen page). Factor into a reusable `EventMediaHeader` with clear API for hero tags and gestures.
- **Introduce theming extensions:** Hard-coded colors (`Colors.white`, `Colors.black`) should defer to theme extensions to ease light/dark mode alignment.
- **Co-locate bottom sheets with features:** `EventCostCalculatorSheet` lives in the same folder as the detail widgets. Consider moving modal sheets to a `sheets/` subfolder for discoverability (already hinted by existing `sheets` directory in repo screenshot).

## Data Layer
- **Normalize media URLs:** Deduplicate `imageUrls`/`videoUrls` at the repository level to avoid filtering duplicates in the UI.
- **Pre-fetch hero images:** Trigger `precacheImage` during list -> detail transition to eliminate first-frame blanking.

## Testing
- **Add golden tests for header stretch:** Capture snapshots for base, stretched, and fullscreen states to prevent regressions.
- **Widget tests for interactions:** Cover follow toggle, cost calculator opening, and fullscreen navigation to ensure refactors keep behavior intact.

