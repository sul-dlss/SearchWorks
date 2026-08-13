import assert from "node:assert/strict"
import test from "node:test"

import EagerLazyController from "../../app/javascript/controllers/eager_lazy_controller.js"

const eagerLazyLoad = EagerLazyController.prototype.eagerLazyLoad
const frameWillLoad = EagerLazyController.prototype.frameWillLoad

const buildFrame = ({ loading = "lazy", busy = false, complete = false } = {}) => ({
  loading,
  dataset: { eagerLazyTarget: "frame" },
  hasAttribute(attribute) {
    return (attribute === "busy" && busy) || (attribute === "complete" && complete)
  }
})

const buildController = (frameTargets) => ({
  frameTargets,
  garbageCollectOtherFrameTargets() {}
})

test("eagerLazyLoad promotes the next idle lazy frame", () => {
  const frame = buildFrame()

  eagerLazyLoad.call(buildController([frame]))

  assert.equal(frame.loading, "eager")
  assert.equal(frame.dataset.eagerLazyTarget, undefined)
})

test("eagerLazyLoad does not restart a lazy frame that Turbo is already loading", () => {
  const frame = buildFrame({ busy: true })

  eagerLazyLoad.call(buildController([frame]))

  assert.equal(frame.loading, "lazy")
  assert.equal(frame.dataset.eagerLazyTarget, "frame")
})

test("frameWillLoad removes a frame from the queue before Turbo marks it busy", () => {
  const frame = buildFrame()
  const controller = buildController([frame])

  frameWillLoad.call(controller, { target: frame })
  eagerLazyLoad.call(controller)

  assert.equal(frame.loading, "lazy")
  assert.equal(frame.dataset.eagerLazyTarget, undefined)
})
