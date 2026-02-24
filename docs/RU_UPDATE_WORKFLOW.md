# RU Fork Upstream Update Workflow

This document defines a repeatable, non-invasive process for applying upstream mirror updates while preserving the RU localization overlay.

## Safety Constraints

- Do not patch the minified gameplay bundle (`index-*.js`) unless explicitly approved as an exception.
- Keep save compatibility and storage keys unchanged:
  - `evercraft-idle-save`
  - `evercraft-idle-timestamp`
  - `evercraft-idle-settings`
- Keep RU default and EN fallback behavior intact.

## Prerequisites

- Repo remotes:
  - `origin` -> `TerraTectra/evercraft-idle`
  - `upstream` -> `gityxs/evercraft-idle`
- Start from a clean `main`.

```powershell
git checkout main
git pull --ff-only origin main
git fetch upstream --prune
```

## 1) Compare Current Baseline vs Upstream HEAD

Read the current upstream baseline short SHA from `UPSTREAM.md` (`Current Baseline` section).

```powershell
# Example baseline from UPSTREAM.md
$baseline = "db90982"

git rev-parse --short upstream/main
git log --oneline "$baseline..upstream/main"
git diff --name-status "$baseline..upstream/main"
```

If there are no commits in that range, no upstream sync is needed.

## 2) Create Update Branch

```powershell
$newSha = (git rev-parse --short upstream/main).Trim()
git checkout -b "update/upstream-$newSha" main
```

## 3) Integrate Upstream Changes

Use one of these:

- Preferred when upstream history should remain visible:

```powershell
git merge --no-ff upstream/main
```

- If only selected commits are needed:

```powershell
git cherry-pick <commit1> <commit2>
```

## 4) Reapply / Verify RU Overlay Files

Confirm these invariants:

- `index.html`:
  - includes `lang.js`
  - includes hashed gameplay bundle script `index-*.js`
  - does **not** directly inject `chs.js`/`core.js` legacy scripts
- `lang.js`:
  - still uses `evercraft-locale`
  - still loads `./ru.js`
  - still falls back to EN on RU load failure
- `ru.js` exists and remains UTF-8 text content
- `core.js` still compatible with the dictionary/observer flow

Run structural check:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-ru-compat.ps1
```

## 5) Run Smoke Tests

Minimum smoke pass before merge:

1. Local startup from static server.
2. RU default loads.
3. EN fallback works when `ru.js` is blocked/fails.
4. No blank page / no fatal startup errors.
5. Core screens + settings/export/import UI present.

## 6) Update Baseline Metadata

Append a new row to `UPSTREAM.md` under `RU Release History (Append-Only)`:

- Date (UTC)
- Upstream short SHA
- RU tag
- Notes (for example: no bundle patching)

Update `Current Baseline` fields to the new upstream SHA/tag.

## 7) Release Tagging

```powershell
# Example
git checkout main
git merge --ff-only "update/upstream-$newSha"
git tag -a "ru-v1.0.1+upstream-$newSha" -m "RU update release (upstream $newSha)"
git push origin main
git push origin "ru-v1.0.1+upstream-$newSha"
```

## 8) Deploy and Verify Live

- Ensure GitHub Pages source is `main` path `/`.
- Re-verify live URL for RU default, EN fallback, and save import/export UI.

## Risks to Watch

- Upstream renames hashed bundle assets and/or changes `index.html` load order.
- Upstream changes DOM text generation patterns, increasing untranslated strings.
- Upstream reintroduces direct translation script injection patterns.
- UI layout changes can create RU overflow/truncation in narrow components.
