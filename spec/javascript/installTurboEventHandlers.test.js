import assert from "node:assert/strict"
import test from "node:test"

test("installs the frame fetch handler when its module loads", async() => {
  const originalDocument = globalThis.document
  const listeners = new Map()
  globalThis.document = {
    addEventListener(name, handler) {
      listeners.set(name, handler)
    }
  }

  try {
    await import(`../../app/javascript/turbo/installEventHandlers.js?test=${Date.now()}`)

    assert.equal(typeof listeners.get("turbo:before-fetch-request"), "function")
    assert.equal(typeof listeners.get("turbo:frame-missing"), "function")
    assert.equal(typeof listeners.get("turbo:before-cache"), "function")
  } finally {
    globalThis.document = originalDocument
  }
})
