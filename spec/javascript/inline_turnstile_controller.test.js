import assert from "node:assert/strict"
import test from "node:test"

import InlineTurnstileController from "../../app/javascript/controllers/inline_turnstile_controller.js"

const convertFrame = InlineTurnstileController.prototype.convertFrame

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
