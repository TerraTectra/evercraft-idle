# Upstream Tracking

## Source Mirror

- Repository: `https://github.com/gityxs/evercraft-idle`
- Base branch: `main`
- Base commit for RU fork: `db90982e4bae9f98ec1b1c4f0acf1450598dc499`

## Branching Strategy

- Working branch for RU localization: `feat/ru-localization-overlay`
- Keep localization isolated in overlay/bootstrap/docs files.
- Do not patch minified gameplay bundle unless a blocker is proven.

## Rebase / Refresh Procedure

1. Update from upstream `main`.
2. Re-apply or resolve only:
   - `index.html` loader wiring and third-party script removal
   - `lang.js`
   - `ru.js`
   - docs updates
3. Verify save compatibility and key gameplay loops (no mechanic changes).

## Deployment Notes

- Save keys used by the built game are unchanged.
- Saves remain origin-scoped by browser localStorage rules.
- Cross-origin migration must use export/import.
