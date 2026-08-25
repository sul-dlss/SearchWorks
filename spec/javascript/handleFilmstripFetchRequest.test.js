import assert from "node:assert/strict"
import { readFile } from "node:fs/promises"
import test, { afterEach } from "node:test"

import handleFilmstripFetchRequest from "../../app/javascript/turbo/handleFilmstripFetchRequest.js"

const originalFetch = globalThis.fetch

const buildEvent = (id = "filmstrip_MFILM-N.S.-11047:4") => ({
  target: { id },
  detail: {
    fetchOptions: { headers: { "Turbo-Frame": id } },
    url: new URL("https://example.com/browse/nearby?start=3030710")
  }
})

afterEach(() => { globalThis.fetch = originalFetch })

test("registers the interceptor before Turbo starts eager frame requests", async() => {
  const entrypoint = await readFile(new URL("../../app/javascript/searchworks4.js", import.meta.url), "utf8")
  const registrationIndex = entrypoint.indexOf('import "./turbo/registerEventHandlers"')
  const turboIndex = entrypoint.indexOf('import "@hotwired/turbo-rails"')

  assert.notEqual(registrationIndex, -1)
  assert.ok(registrationIndex < turboIndex)
})

test("turns a filmstrip network failure into an empty frame response", async() => {
  globalThis.fetch = async() => { throw new TypeError("Failed to fetch") }
  const event = buildEvent()

  handleFilmstripFetchRequest(event)
  const response = await event.detail.fetchRequest.response

  assert.equal(response.status, 503)
  assert.equal(await response.text(), '<turbo-frame id="filmstrip_MFILM-N.S.-11047:4"></turbo-frame>')
})

test("uses a successful filmstrip response", async() => {
  const successfulResponse = new Response("filmstrip", { status: 200 })
  const event = buildEvent()
  let request
  globalThis.fetch = async(url, options) => {
    request = { options, url }
    return successfulResponse
  }

  handleFilmstripFetchRequest(event)

  assert.equal(await event.detail.fetchRequest.response, successfulResponse)
  assert.equal(request.url, event.detail.url)
  assert.equal(request.options, event.detail.fetchOptions)
})

test("allows Turbo to fetch non-filmstrip frames", () => {
  let fetched = false
  globalThis.fetch = async() => { fetched = true }
  const event = buildEvent("availability_solr_document_3030710")

  handleFilmstripFetchRequest(event)

  assert.equal(event.detail.fetchRequest, undefined)
  assert.equal(fetched, false)
})

test("preserves abort errors", async() => {
  const abortError = new Error("The operation was aborted")
  abortError.name = "AbortError"
  globalThis.fetch = async() => { throw abortError }
  const event = buildEvent()

  handleFilmstripFetchRequest(event)

  await assert.rejects(event.detail.fetchRequest.response, abortError)
})

test("wraps a response supplied by another Turbo request interceptor", async() => {
  const cachedResponse = new Response("cached", { status: 200 })
  const event = buildEvent()
  event.detail.fetchRequest = { response: Promise.resolve(cachedResponse) }

  handleFilmstripFetchRequest(event)

  assert.equal(await event.detail.fetchRequest.response, cachedResponse)
})
