import assert from "node:assert/strict"
import test from "node:test"

import PreviewController from "../../app/javascript/controllers/preview_controller.js"

const load = PreviewController.prototype.load
const reset = PreviewController.prototype.reset

test("load restores a preview frame removed by Turbo before resetting it", () => {
  const frame = {
    innerHTML: "stale preview",
    attributes: {},
    setAttribute(name, value) {
      this.attributes[name] = value
    }
  }
  const controller = {
    idValue: "old-document",
    appendFrame() {
      this.frameTarget = frame
    },
    reset,
    open() {}
  }

  assert.doesNotThrow(() => load.call(controller, "new-document", "/catalog/new-document/preview"))
  assert.equal(frame.innerHTML, "")
  assert.equal(frame.attributes.id, "preview_new-document")
  assert.equal(frame.attributes.src, "/catalog/new-document/preview")
})
