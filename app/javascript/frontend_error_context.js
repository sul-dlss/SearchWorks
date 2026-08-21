let turboVisitAction = null

export const recordTurboVisit = (event) => {
  turboVisitAction = event.detail?.action || null
}

export const frontendErrorContext = ({
  documentObject = document,
  performanceObject = performance,
  now = Date.now()
} = {}) => {
  const assetVersionElement = documentObject.querySelector('[data-controller~="asset-version"]')
  const renderedAt = Number(assetVersionElement?.dataset.assetVersionLoadedAtValue)

  return {
    asset_revision: assetVersionElement?.dataset.assetVersionRevisionValue || null,
    page_age_seconds: Math.round(performanceObject.now() / 1000),
    server_rendered_page_age_seconds: renderedAt ? Math.max(0, Math.round(now / 1000 - renderedAt)) : null,
    turbo_restored: turboVisitAction === "restore",
    turbo_visit_action: turboVisitAction
  }
}

if (typeof document !== "undefined") {
  document.addEventListener("turbo:visit", recordTurboVisit)
}

if (typeof window !== "undefined") {
  window.searchworksFrontendErrorContext = frontendErrorContext
}
