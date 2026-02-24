# RU Localization Fork Release Notes

## Release

- Version: `ru-v1.0.0+upstream-db90982`
- Fork: `https://github.com/TerraTectra/evercraft-idle`
- Upstream mirror baseline: `gityxs/evercraft-idle@db90982`

## Included

- Russian localization overlay enabled by default (`evercraft-locale=ru`).
- English fallback preserved and fail-safe startup kept:
  - if RU localization assets fail to load, UI falls back to EN without blank page.
- Non-invasive implementation:
  - no gameplay bundle patching
  - gameplay mechanics/storage logic unchanged.

## Update: Global Speed Multiplier

- Added non-invasive global time multiplier bootstrap (`speed.js`), loaded before the gameplay bundle.
- Default multiplier: `x10` (stored in `localStorage["evercraft-speed-multiplier"]`).
- Time scaling now covers `Date.now`, `performance.now`, `setTimeout`/`setInterval`, and `requestAnimationFrame` timestamp flow.
- Runtime controls are available via browser console:
  - `window.evercraftSpeed.getMultiplier()`
  - `window.evercraftSpeed.setMultiplier(value)`
  - `window.evercraftSpeed.reset()` for `x1`.
  - `window.evercraftSpeed.debugSnapshot()` for quick verification.
- Gameplay bundle (`index-*.js`) remains unmodified.

## Save Migration Note

- Saves are browser origin-scoped (`localStorage`).
- Moving between different domains/origins requires in-game **Export Save** / **Import Save**.
- Automatic localStorage carry-over between origins is not expected.

## Debug Untranslated Logging Mode

- Enable untranslated string logging:
  - `localStorage.setItem("evercraft-ru-debug-untranslated", "1"); location.reload();`
- Disable:
  - `localStorage.setItem("evercraft-ru-debug-untranslated", "0"); location.reload();`
- One-time URL flags are also supported:
  - `?ru_debug=1` or `?ru_debug=0`

## Known Limitation

- Late-game/deep-progression text may still require incremental RU coverage updates as more states are reached.
