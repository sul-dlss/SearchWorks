import assert from "node:assert/strict"
import test, { afterEach } from "node:test"

import handleFrameFetchRequest from "../../app/javascript/turbo/handleFrameFetchRequest.js"

const originalFetch = globalThis.fetch

const buildEvent = (id = "filmstrip_MFILM-N.S.-11047:4") => ({
  target: { id },
  detail: {
    fetchOptions: { headers: { "Turbo-Frame": id } },
    url: new URL("https://example.com/browse/nearby?start=3030710")
  }
})

afterEach(() => { globalThis.fetch = originalFetch })

test("turns a filmstrip network failure into an empty frame response", async() => {
  globalThis.fetch = async() => { throw new TypeError("Failed to fetch") }
  const event = buildEvent()

  handleFrameFetchRequest(event)
  const response = await event.detail.fetchRequest.response

  assert.equal(response.status, 503)
  assert.equal(await response.text(), '<turbo-frame id="filmstrip_MFILM-N.S.-11047:4"></turbo-frame>')
})

test("turns Safari availability load failures into an empty frame response", async() => {
  globalThis.fetch = async() => { throw new TypeError("Load failed") }
  const event = buildEvent("availability_solr_document_5574017")
  event.detail.url = new URL("https://example.com/availability/5574017")

  handleFrameFetchRequest(event)
  const response = await event.detail.fetchRequest.response

  assert.equal(response.status, 503)
  assert.equal(await response.text(), '<turbo-frame id="availability_solr_document_5574017"></turbo-frame>')
})

test("uses a successful frame response", async() => {
  const successfulResponse = new Response("filmstrip", { status: 200 })
  const event = buildEvent()
  let request
  globalThis.fetch = async(url, options) => {
    request = { options, url }
    return successfulResponse
  }

  handleFrameFetchRequest(event)

  assert.equal(await event.detail.fetchRequest.response, successfulResponse)
  assert.equal(request.url, event.detail.url)
  assert.equal(request.options, event.detail.fetchOptions)
})

test("allows Turbo to fetch unrelated frames", () => {
  let fetched = false
  globalThis.fetch = async() => { fetched = true }
  const event = buildEvent("unhandled_frame")

  handleFrameFetchRequest(event)

  assert.equal(event.detail.fetchRequest, undefined)
  assert.equal(fetched, false)
})

test("preserves abort errors for Turbo to handle", async() => {
  const abortError = new Error("The operation was aborted")
  abortError.name = "AbortError"
  globalThis.fetch = async() => { throw abortError }
  const event = buildEvent("availability_solr_document_5574017")

  handleFrameFetchRequest(event)

  await assert.rejects(event.detail.fetchRequest.response, abortError)
})

test("wraps a response supplied by another Turbo request interceptor", async() => {
  const cachedResponse = new Response("cached", { status: 200 })
  const event = buildEvent()
  event.detail.fetchRequest = { response: Promise.resolve(cachedResponse) }

  handleFrameFetchRequest(event)

  assert.equal(await event.detail.fetchRequest.response, cachedResponse)
})
