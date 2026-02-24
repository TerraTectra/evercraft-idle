# Evercraft Idle (RU Localization Fork)

This repository is a Russian-localized fork of the publicly mirrored built web version of Evercraft Idle.

## Scope

- Keeps gameplay logic and mechanics unchanged.
- Adds a non-invasive Russian localization overlay (`ru.js` + `core.js`) on top of the built bundle.
- Keeps English fallback if localization cannot be loaded.

## Save Data and Migration

Save data is stored in `localStorage`, which is **origin-scoped** by browser rules.

- Different domain/subdomain/port = different `localStorage`.
- Your save does **not** transfer automatically between mirrors/domains.
- To migrate saves between origins, use in-game **Export Save** and **Import Save**.

## Language Behavior

- Default locale for this fork: `ru`.
- Fallback locale: `en` (automatic if RU overlay fails to load).
- Current locale key in storage: `evercraft-locale`.

Set English manually from browser console:

```js
localStorage.setItem("evercraft-locale", "en");
location.reload();
```

Set Russian manually from browser console:

```js
localStorage.setItem("evercraft-locale", "ru");
location.reload();
```

## Global Speed Multiplier

- Default speed multiplier in this fork: `x5`.
- Stored in `localStorage` key: `evercraft-speed-multiplier`.
- Applied as a non-invasive runtime time-scale layer (no gameplay bundle patching).
- Affects active and offline time-based progression.

Check current multiplier:

```js
window.evercraftSpeed.getMultiplier();
```

Set multiplier and reload:

```js
window.evercraftSpeed.setMultiplier(5);
```

Emergency reset to normal speed (`x1`):

```js
window.evercraftSpeed.reset();
```

Manual storage fallback:

```js
localStorage.setItem("evercraft-speed-multiplier", "1");
location.reload();
```

Quick verification:

```js
window.evercraftSpeed.debugSnapshot();
```

If speed is not noticeable, force x5 and reload:

```js
localStorage.setItem("evercraft-speed-multiplier", "5");
location.reload();
```

## Developer Mode: Untranslated String Logging

Use developer-only logging to collect missing translations in console.

Enable:

```js
localStorage.setItem("evercraft-ru-debug-untranslated", "1");
location.reload();
```

Disable:

```js
localStorage.setItem("evercraft-ru-debug-untranslated", "0");
location.reload();
```

One-time enable via URL:

- `?ru_debug=1` enables
- `?ru_debug=0` disables

Unknown strings are captured in `cnItems._OTHER_` and printed to browser console when debug mode is on.

## Attribution / Usage

- Upstream mirror: `https://github.com/gityxs/evercraft-idle`
- Translation plugin base: Guoba web translation script pattern (`chs.js`/`core.js` style)
- Intended for personal/non-commercial use unless upstream licensing states otherwise.
