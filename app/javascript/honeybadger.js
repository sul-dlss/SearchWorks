const EMPTY_PROMISE_REJECTION_MESSAGES = new Set([
  "UnhandledPromiseRejectionWarning: {}",
  "UnhandledPromiseRejectionWarning: Unspecified reason"
])
// CefSharp is a .NET wrapper around embedded Chromium used by automated scanners such as email link checkers.
// This signature comes from its JavaScript-to-.NET object binding and does not indicate a failure in SearchWorks.
const CEFSHARP_PROMISE_REJECTION_MESSAGE =
  /^UnhandledPromiseRejectionWarning: Object Not Found Matching Id:\d+, MethodName:[^,]+, ParamCount:\d+$/
const BROWSER_EXTENSION_STACK = /(?:chrome|moz|safari-web|ms-browser)-extension:\/\//

export function ignoreHoneybadgerNotice(notice) {
  return notice.name === "TurnstileError" ||
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
