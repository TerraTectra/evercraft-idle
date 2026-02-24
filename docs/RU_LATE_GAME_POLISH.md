# RU Late-Game Translation Polish Workflow

This guide describes a safe, repeatable process for finding and patching long-tail untranslated strings in late-game progression without touching gameplay bundle code.

## Safety Rules

- Do not edit minified gameplay bundle files (`index-*.js`).
- Keep RU default / EN fallback behavior unchanged.
- Keep numeric formatting logic untouched; translate surrounding text only.
- Keep save compatibility keys unchanged:
  - `evercraft-idle-save`
  - `evercraft-idle-timestamp`
  - `evercraft-idle-settings`

## 1) Run in RU Debug Untranslated Mode

Open the game and enable debug mode in browser console:

```js
localStorage.setItem("evercraft-ru-debug-untranslated", "1");
localStorage.setItem("evercraft-locale", "ru");
location.reload();
```

Expected behavior:

- `core.js` logs unknown strings via untranslated debug entries.
- These are candidates for late-game RU polishing.

Disable debug mode after collection:

```js
localStorage.setItem("evercraft-ru-debug-untranslated", "0");
location.reload();
```

## 2) Collect Logs During Longer Progression Sessions

Use helper script (recommended):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\capture-ru-untranslated.ps1
```

The helper:

- ensures local static server is running (starts one if needed)
- opens the local game URL
- writes session logs/notes to `logs/ru-untranslated/`
- tries automated console capture (Playwright) and falls back to manual capture instructions when unavailable

For longer sessions, run with a larger capture duration:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\capture-ru-untranslated.ps1 -CaptureSeconds 300
```

## 3) Classify Unknown Strings

Classify each unknown line before patching:

- `static`:
  - fixed labels/buttons/messages
  - patch via `cnItems`
- `dynamic`:
  - contains numbers/timers/rates/tiers/percentages
  - patch via `cnRegReplace` (or `cnPrefix` / `cnPostfix` when appropriate)
- `noise`:
  - symbols, CSS fragments, transient dev/runtime noise
  - suppress with exclusions (`cnExcludeWhole`) only when safe

Use `docs/RU_TRANSLATION_TRIAGE_TEMPLATE.md` for each item.

## 4) Patch `ru.js` Safely

Preferred patch order:

1. Exact `cnItems` entry for stable labels.
2. Targeted `cnRegReplace` for parameterized strings.
3. `cnPrefix` / `cnPostfix` for repeated bounded fragments.
4. Exclusions only for confirmed non-user-facing noise.

Do not:

- add broad regex that can match numeric-only tokens unexpectedly
- translate unit/number formatting in ways that alter value semantics
- remove fallback behavior in `lang.js`

## 5) Regression-Check Numeric Integrity

After each patch set:

1. Startup check:
   - RU default loads
   - EN fallback still works if RU script load fails
   - no blank page / no fatal startup errors
2. Numeric text sanity:
   - rates (`/s`, `/min`, `/hr`)
   - scientific notation (`1e...`)
   - multipliers (`x`)
   - percentages (`%`)
   - tier labels (`T1...Tn`)
3. Ensure values remain unchanged, only surrounding language changes.

## 6) Suggested Session Flow

1. Run capture helper.
2. Play naturally through unlocked/late-game systems.
3. Export unknowns into triage entries.
4. Patch small safe batch in `ru.js`.
5. Re-run smoke checks.
6. Commit with clear message (for example: `i18n: late-game RU polish batch N`).

## 7) Fast Commands

```powershell
# Structural compatibility quick check
powershell -ExecutionPolicy Bypass -File .\scripts\check-ru-compat.ps1

# Capture helper
powershell -ExecutionPolicy Bypass -File .\scripts\capture-ru-untranslated.ps1 -CaptureSeconds 180
```
