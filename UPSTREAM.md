# Upstream Tracking

## Source Mirror

- Repository: `https://github.com/gityxs/evercraft-idle`
- Upstream branch: `main`

## Current Baseline

- Upstream full SHA: `db90982e4bae9f98ec1b1c4f0acf1450598dc499`
- Upstream short SHA: `db90982`
- Current RU release tag: `ru-v1.0.0+upstream-db90982`
- Implementation policy: non-invasive overlay, no gameplay bundle patching

## RU Release History (Append-Only)

| Date (UTC) | Upstream Short SHA | RU Tag | Notes |
| --- | --- | --- | --- |
| 2026-02-24 | `db90982` | `ru-v1.0.0+upstream-db90982` | Initial RU overlay release. No minified gameplay bundle patching. |

## Branching Strategy

- Active release branch: `main`
- Typical update branch naming: `update/upstream-<shortsha>`
- Keep localization isolated in overlay/bootstrap/docs files.

## Rebase / Refresh Rules

1. Update from upstream `main`.
2. Re-apply or resolve only RU overlay and docs files:
   - `index.html` loader wiring and third-party script removal state
   - `lang.js`
   - `ru.js`
   - `core.js` (translation runtime compatibility only)
   - maintenance docs/check scripts
3. Verify save compatibility and key gameplay loops (no mechanic changes).

## Deployment Notes

- Save keys used by the built game are unchanged:
  - `evercraft-idle-save`
  - `evercraft-idle-timestamp`
  - `evercraft-idle-settings`
- Saves remain origin-scoped by browser localStorage rules.
- Cross-origin migration requires export/import.
