import assert from "node:assert/strict"
import test from "node:test"

import GalleryRowController from "../../app/javascript/controllers/gallery_row_controller.js"

const adjustPreviewMargins = GalleryRowController.prototype.adjustPreviewMargins
const disconnect = GalleryRowController.prototype.disconnect
const galleryCardOutletDisconnected = GalleryRowController.prototype.galleryCardOutletDisconnected

test("adjustPreviewMargins ignores a selected card removed by a Turbo frame render", () => {
  const selectedCard = {}
  const controller = {
    currentPreview: selectedCard,
    galleryCardOutlets: [],
    hasPreviewOutlet: true
  }

  assert.doesNotThrow(() => adjustPreviewMargins.call(controller))
  assert.equal(controller.currentPreview, undefined)
})

test("disconnect clears the selected card retained by a Stimulus controller reconnect", () => {
  const controller = { currentPreview: {} }

  disconnect.call(controller)

  assert.equal(controller.currentPreview, undefined)
})

test("disconnecting the selected gallery card clears it", () => {
  const selectedCard = {}
  const controller = { currentPreview: selectedCard }

  galleryCardOutletDisconnected.call(controller, {}, selectedCard)

  assert.equal(controller.currentPreview, undefined)
})
