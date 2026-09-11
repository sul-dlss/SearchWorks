import assert from "node:assert/strict"
import test from "node:test"

import InlineTurnstileController from "../../app/javascript/controllers/inline_turnstile_controller.js"

const convertFrame = InlineTurnstileController.prototype.convertFrame
const handleChallengeResponse = InlineTurnstileController.prototype.handleChallengeResponse

const buildFrame = ({ src, disabled }) => ({
  src,
  disabled,
  hasAttribute(attribute) {
    return attribute === "disabled" && this.disabled
  },
  removeAttribute(attribute) {
    if (attribute === "disabled") this.disabled = false
  }
})

test("convertFrame decodes and enables a challenge-gated frame", () => {
  const frame = buildFrame({
    src: btoa("/availability/7617682"),
    disabled: true
  })

  convertFrame.call({}, frame)

  assert.equal(frame.src, "/availability/7617682")
  assert.equal(frame.disabled, false)
})

test("convertFrame ignores a frame already enabled before Stimulus reconnects", () => {
  const frame = buildFrame({
    src: "/availability/7617682",
    disabled: false
  })

  assert.doesNotThrow(() => convertFrame.call({}, frame))
  assert.equal(frame.src, "/availability/7617682")
})

test("handleChallengeResponse handles a failed challenge request", async () => {
  const originalFetch = globalThis.fetch
  const originalDocument = globalThis.document
  const originalWindow = globalThis.window
  const originalConsoleError = console.error
  const errors = []

  globalThis.fetch = async () => {
    throw new TypeError("Load failed")
  }
  globalThis.document = { querySelector: () => null }
  globalThis.window = {}
  console.error = (...args) => errors.push(args)

  try {
    await assert.doesNotReject(() => handleChallengeResponse.call({
      challengePathValue: "/challenge"
    }, "turnstile-token"))
  } finally {
    globalThis.fetch = originalFetch
    globalThis.document = originalDocument
    globalThis.window = originalWindow
    console.error = originalConsoleError
  }

  assert.equal(errors.length, 1)
  assert.equal(errors[0][0], "Problem verifying Turnstile challenge")
  assert.equal(errors[0][1], "/challenge")
  assert.equal(errors[0][2].message, "Load failed")
})
