import assert from "node:assert/strict"
import test from "node:test"

import { frontendErrorContext, recordTurboVisit } from "../../app/javascript/frontend_error_context.js"

const documentObject = {
  querySelector() {
    return {
      dataset: {
        assetVersionLoadedAtValue: "1000",
        assetVersionRevisionValue: "abc123"
      }
    }
  }
}

const performanceObject = { now: () => 12_345 }

test("frontendErrorContext describes the age and revision of the current page", () => {
  recordTurboVisit({ detail: { action: "advance" } })

  assert.deepEqual(frontendErrorContext({ documentObject, performanceObject, now: 1_100_000 }), {
    asset_revision: "abc123",
    page_age_seconds: 12,
    server_rendered_page_age_seconds: 100,
    turbo_restored: false,
    turbo_visit_action: "advance"
  })
})

test("frontendErrorContext identifies a page restored by Turbo", () => {
  recordTurboVisit({ detail: { action: "restore" } })

  const context = frontendErrorContext({ documentObject, performanceObject, now: 1_100_000 })

  assert.equal(context.turbo_restored, true)
  assert.equal(context.turbo_visit_action, "restore")
})
