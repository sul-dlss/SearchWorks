const EMPTY_PROMISE_REJECTION_MESSAGES = new Set([
  "UnhandledPromiseRejectionWarning: {}",
  "UnhandledPromiseRejectionWarning: Unspecified reason"
])
// CefSharp is a .NET wrapper around embedded Chromium used by automated scanners such as email link checkers.
// This signature comes from its JavaScript-to-.NET object binding and does not indicate a failure in SearchWorks.
const CEFSHARP_PROMISE_REJECTION_MESSAGE =
  /^UnhandledPromiseRejectionWarning: Object Not Found Matching Id:\d+, MethodName:[^,]+, ParamCount:\d+$/
const BROWSER_EXTENSION_STACK = /(?:chrome|moz|safari-web|ms-browser)-extension:\/\//
// Firefox raises this when privileged code (extensions, automation tools) touches a DOM wrapper from a
// window that has been torn down. Page scripts cannot create such wrappers, so it never originates in SearchWorks.
const FIREFOX_DEAD_OBJECT_MESSAGE = "can't access dead object"
// Script parse failures reported via window.onerror carry no stack frames. They come from clients that
// can't parse our bundle (e.g. scrapers running an outdated engine behind a spoofed modern user agent,
// which report "Unexpected token .") or that received an HTML page in place of a script ("Unexpected token '<'").
const UNEXPECTED_TOKEN_MESSAGE = /^Unexpected token /

function isFramelessParseError(notice) {
  return notice.name === "SyntaxError" &&
    UNEXPECTED_TOKEN_MESSAGE.test(notice.message) &&
    !(notice.stack || "").includes("\n")
}

export function ignoreHoneybadgerNotice(notice) {
  return notice.name === "TurnstileError" ||
    notice.message === FIREFOX_DEAD_OBJECT_MESSAGE ||
    isFramelessParseError(notice) ||
    (notice.name === "window.onunhandledrejection" &&
      (EMPTY_PROMISE_REJECTION_MESSAGES.has(notice.message) ||
        CEFSHARP_PROMISE_REJECTION_MESSAGE.test(notice.message) ||
        BROWSER_EXTENSION_STACK.test(notice.stack)))
}

export function configureHoneybadgerFilters(honeybadger = globalThis.Honeybadger) {
  if (!honeybadger) return

  honeybadger.beforeNotify((notice) => {
    if (ignoreHoneybadgerNotice(notice)) return false
  })
}
