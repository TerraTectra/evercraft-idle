# RU Upstream Update Checklist

Use this checklist for every upstream sync.

- [ ] Fetch upstream: `git fetch upstream --prune`
- [ ] Branch from `main`: `update/upstream-<shortsha>`
- [ ] Merge/cherry-pick upstream changes into update branch
- [ ] Verify `index.html` script wiring still intact
- [ ] Verify `lang.js`, `ru.js`, `core.js` compatibility
- [ ] Run structural checker: `scripts/check-ru-compat.ps1`
- [ ] Run local smoke tests (RU default, EN fallback, no blank page)
- [ ] Verify save/export/import UI is present
- [ ] Merge update branch into `main`
- [ ] Verify live build after deploy (Pages source + runtime sanity)
- [ ] Append new baseline row to `UPSTREAM.md`
- [ ] Tag release: `ru-vX.Y.Z+upstream-<shortsha>`
