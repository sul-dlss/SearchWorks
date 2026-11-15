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
// Google's reCAPTCHA script (loaded for the feedback/email forms on every page) polls on a timer and, in
// Firefox, throws this internal XPCOM error once the browser has torn down the resource it touches.
// It repeats every second until the page is closed and is not something SearchWorks can act on.
const FIREFOX_NOT_INITIALIZED_NAME = "NS_ERROR_NOT_INITIALIZED"
const RECAPTCHA_STACK = /https:\/\/www\.gstatic\.com\/recaptcha\//

export function ignoreHoneybadgerNotice(notice) {
  return notice.name === "TurnstileError" ||
    notice.message === FIREFOX_DEAD_OBJECT_MESSAGE ||
    (notice.name === FIREFOX_NOT_INITIALIZED_NAME && RECAPTCHA_STACK.test(notice.stack)) ||
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
