/*
  Fail-safe language bootstrap for built Evercraft Idle mirror.
  Defaults to Russian overlay but never blocks EN gameplay startup.
*/
(function () {
  "use strict";

  var LOCALE_KEY = "evercraft-locale";
  var RU_DEBUG_KEY = "evercraft-ru-debug-untranslated";
  var DEFAULT_LOCALE = "ru";

  function safeGetStorage(key) {
    try {
      return window.localStorage.getItem(key);
    } catch (err) {
      return null;
    }
  }

  function safeSetStorage(key, value) {
    try {
      window.localStorage.setItem(key, value);
      return true;
    } catch (err) {
      return false;
    }
  }

  function normalizeLocale(value) {
    if (value === "en" || value === "ru") {
      return value;
    }
    return null;
  }

  function readLocale() {
    var stored = normalizeLocale(safeGetStorage(LOCALE_KEY));
    if (stored) {
      return stored;
    }
    safeSetStorage(LOCALE_KEY, DEFAULT_LOCALE);
    return DEFAULT_LOCALE;
  }

  function readDebugFlag() {
    var params;
    try {
      params = new URLSearchParams(window.location.search || "");
      if (params.has("ru_debug")) {
        var value = params.get("ru_debug");
        var enabled = value === "1" || value === "true" || value === "on";
        safeSetStorage(RU_DEBUG_KEY, enabled ? "1" : "0");
        return enabled;
      }
    } catch (err) {
      // Ignore URL parsing issues and continue with storage fallback.
    }
    return safeGetStorage(RU_DEBUG_KEY) === "1";
  }

  function setLocale(locale) {
    var normalized = normalizeLocale(locale);
    if (!normalized) {
      throw new Error("Unsupported locale: " + locale);
    }
    safeSetStorage(LOCALE_KEY, normalized);
    window.__EVERCRAFT_LOCALE__ = normalized;
  }

  function setRuDebug(enabled) {
    var value = enabled ? "1" : "0";
    safeSetStorage(RU_DEBUG_KEY, value);
    window.__RU_TRANSLATION_DEBUG__ = enabled;
  }

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var script = document.createElement("script");
      script.src = src;
      script.async = false;
      script.defer = false;
      script.onload = function () {
        resolve();
      };
      script.onerror = function () {
        reject(new Error("Failed to load " + src));
      };
      document.head.appendChild(script);
    });
  }

  async function bootLocalization() {
    if (window.__EVERCRAFT_LOCALE__ !== "ru") {
      return;
    }
    try {
      await loadScript("./ru.js");
      await loadScript("./core.js");
      console.info("[locale] Russian localization overlay loaded.");
    } catch (err) {
      // Keep gameplay boot path intact by falling back to English UI.
      console.warn("[locale] RU localization failed; continuing in English.", err);
      setLocale("en");
    }
  }

  window.__EVERCRAFT_LOCALE__ = readLocale();
  window.__RU_TRANSLATION_DEBUG__ = readDebugFlag();

  window.evercraftLocalization = {
    getLocale: function () {
      return window.__EVERCRAFT_LOCALE__;
    },
    setLocale: function (locale, reload) {
      setLocale(locale);
      if (reload !== false) {
        window.location.reload();
      }
    },
    getRuDebug: function () {
      return !!window.__RU_TRANSLATION_DEBUG__;
    },
    setRuDebug: function (enabled, reload) {
      setRuDebug(!!enabled);
      if (reload !== false) {
        window.location.reload();
      }
    }
  };

  bootLocalization();
})();
