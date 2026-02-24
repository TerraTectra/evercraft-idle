/*
  Non-invasive global time multiplier bootstrap.
  Must load before the minified gameplay bundle.
*/
(function () {
  "use strict";

  try {
    var SPEED_KEY = "evercraft-speed-multiplier";
    var DEFAULT_MULTIPLIER = 10;
    var MIN_MULTIPLIER = 1;
    var MAX_MULTIPLIER = 20;

    var realDateNow = Date.now.bind(Date);
    var perfObj = typeof window !== "undefined" ? window.performance : null;
    var realPerfNow =
      perfObj && typeof perfObj.now === "function"
        ? perfObj.now.bind(perfObj)
        : null;
    var realSetTimeout =
      typeof window.setTimeout === "function"
        ? window.setTimeout.bind(window)
        : null;
    var realSetInterval =
      typeof window.setInterval === "function"
        ? window.setInterval.bind(window)
        : null;
    var realRequestAnimationFrame =
      typeof window.requestAnimationFrame === "function"
        ? window.requestAnimationFrame.bind(window)
        : null;

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

    function clampMultiplier(value, fallback) {
      var n = Number(value);
      if (!Number.isFinite(n)) {
        return fallback;
      }
      if (n < MIN_MULTIPLIER) {
        return MIN_MULTIPLIER;
      }
      if (n > MAX_MULTIPLIER) {
        return MAX_MULTIPLIER;
      }
      return n;
    }

    function readMultiplier() {
      var stored = safeGetStorage(SPEED_KEY);
      if (stored === null || stored === "") {
        safeSetStorage(SPEED_KEY, String(DEFAULT_MULTIPLIER));
        return DEFAULT_MULTIPLIER;
      }
      var normalized = clampMultiplier(stored, DEFAULT_MULTIPLIER);
      if (String(normalized) !== String(stored)) {
        safeSetStorage(SPEED_KEY, String(normalized));
      }
      return normalized;
    }

    var multiplier = readMultiplier();
    var anchorRealDate = realDateNow();
    var anchorScaledDate = anchorRealDate;
    var anchorRealPerf = realPerfNow ? realPerfNow() : 0;
    var anchorScaledPerf = anchorRealPerf;

    function getScaledDateNow(realNow) {
      return anchorScaledDate + (realNow - anchorRealDate) * multiplier;
    }

    function getScaledPerfNow(realNow) {
      return anchorScaledPerf + (realNow - anchorRealPerf) * multiplier;
    }

    function scaleDelay(timeout) {
      var n = Number(timeout);
      if (!Number.isFinite(n) || n < 0) {
        n = 0;
      }
      var scaled = n / (multiplier > 0 ? multiplier : 1);
      return scaled < 0 ? 0 : scaled;
    }

    function applyMultiplier(nextMultiplier) {
      var normalized = clampMultiplier(nextMultiplier, multiplier);
      var nowRealDate = realDateNow();
      var nowScaledDate = getScaledDateNow(nowRealDate);
      var nowRealPerf = realPerfNow ? realPerfNow() : 0;
      var nowScaledPerf = realPerfNow ? getScaledPerfNow(nowRealPerf) : 0;

      multiplier = normalized;
      anchorRealDate = nowRealDate;
      anchorScaledDate = nowScaledDate;
      if (realPerfNow) {
        anchorRealPerf = nowRealPerf;
        anchorScaledPerf = nowScaledPerf;
      }

      safeSetStorage(SPEED_KEY, String(normalized));
      window.__EVERCRAFT_SPEED_MULTIPLIER__ = normalized;
      return normalized;
    }

    try {
      Date.now = function () {
        return Math.floor(getScaledDateNow(realDateNow()));
      };
    } catch (errDate) {
      console.warn("[speed] Could not override Date.now; continuing.", errDate);
    }

    if (realPerfNow) {
      var scaledPerformanceNow = function () {
        return getScaledPerfNow(realPerfNow());
      };
      try {
        perfObj.now = scaledPerformanceNow;
      } catch (errPerfAssign) {
        try {
          Object.defineProperty(perfObj, "now", {
            configurable: true,
            writable: true,
            value: scaledPerformanceNow
          });
        } catch (errPerfDefine) {
          console.warn(
            "[speed] Could not override performance.now; continuing.",
            errPerfDefine
          );
        }
      }
    }

    if (realSetTimeout) {
      window.setTimeout = function (handler, timeout) {
        var args = Array.prototype.slice.call(arguments, 2);
        var scaledTimeout = scaleDelay(timeout);
        return realSetTimeout.apply(window, [handler, scaledTimeout].concat(args));
      };
    }

    if (realSetInterval) {
      window.setInterval = function (handler, timeout) {
        var args = Array.prototype.slice.call(arguments, 2);
        var scaledTimeout = scaleDelay(timeout);
        return realSetInterval.apply(window, [handler, scaledTimeout].concat(args));
      };
    }

    if (realRequestAnimationFrame) {
      window.requestAnimationFrame = function (callback) {
        if (typeof callback !== "function") {
          return realRequestAnimationFrame(callback);
        }
        return realRequestAnimationFrame(function (timestamp) {
          var realTs =
            typeof timestamp === "number"
              ? timestamp
              : realPerfNow
                ? realPerfNow()
                : realDateNow();
          var scaledTs = realPerfNow
            ? getScaledPerfNow(realTs)
            : getScaledDateNow(realTs);
          return callback(scaledTs);
        });
      };
    }

    window.__EVERCRAFT_SPEED_MULTIPLIER__ = multiplier;
    window.evercraftSpeed = {
      getMultiplier: function () {
        return window.__EVERCRAFT_SPEED_MULTIPLIER__;
      },
      setMultiplier: function (value, reload) {
        var applied = applyMultiplier(value);
        if (reload !== false) {
          window.location.reload();
        }
        return applied;
      },
      reset: function (reload) {
        var applied = applyMultiplier(1);
        if (reload !== false) {
          window.location.reload();
        }
        return applied;
      },
      debugSnapshot: function () {
        return {
          multiplier: multiplier,
          stored: safeGetStorage(SPEED_KEY),
          scaledDateNow: Date.now(),
          scaledPerfNow: realPerfNow ? perfObj.now() : null
        };
      }
    };

    console.info(
      "[speed] Global time multiplier active: x" + String(multiplier)
    );
  } catch (err) {
    try {
      console.warn(
        "[speed] Speed bootstrap failed; continuing at normal speed.",
        err
      );
    } catch (noop) {
      // Ignore console failures.
    }
  }
})();
