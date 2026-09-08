const EMPTY_PROMISE_REJECTION_MESSAGES = new Set([
  "UnhandledPromiseRejectionWarning: {}",
  "UnhandledPromiseRejectionWarning: Unspecified reason"
])

export function ignoreHoneybadgerNotice(notice) {
  return notice.name === "TurnstileError" ||
    (notice.name === "window.onunhandledrejection" && EMPTY_PROMISE_REJECTION_MESSAGES.has(notice.message))
}

export function configureHoneybadgerFilters(honeybadger = globalThis.Honeybadger) {
  if (!honeybadger) return

  honeybadger.beforeNotify((notice) => {
    if (ignoreHoneybadgerNotice(notice)) return false
  })
}
