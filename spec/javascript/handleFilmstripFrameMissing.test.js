import assert from "node:assert/strict"
import test, { afterEach } from "node:test"

import handleFilmstripFrameMissing, { reportMissingFilmstripFrame } from "../../app/javascript/turbo/handleFilmstripFrameMissing.js"

const buildResponse = (body = "<html>Unexpected response</html>") => ({
  clone() {
    return { text: async() => body }
  },
  headers: {
    get(header) {
      return {
        "content-type": "text/html; charset=utf-8",
        "x-request-id": "request-id"
      }[header]
    }
  },
  redirected: false,
  status: 200,
  statusText: "OK",
  url: "https://example.com/browse/nearby"
})

const buildEvent = (id, response = buildResponse()) => ({
  target: { id },
  detail: { response },
  defaultPrevented: false,
  preventDefault() {
    this.defaultPrevented = true
  }
})

afterEach(() => delete globalThis.Honeybadger)

test("prevents Turbo from raising when a browse nearby filmstrip is missing", async() => {
  globalThis.Honeybadger = { notify() {} }
  const event = buildEvent("filmstrip_DS796-.H757-C44-1998")

  await handleFilmstripFrameMissing(event)

  assert.equal(event.defaultPrevented, true)
})

test("allows Turbo to handle other missing frames normally", () => {
  const event = buildEvent("availability_solr_document_3780342")

  handleFilmstripFrameMissing(event)

  assert.equal(event.defaultPrevented, false)
})

test("reports the missing frame response body to Honeybadger", async() => {
  let notice
  globalThis.Honeybadger = { notify: (error, options) => { notice = { error, options } } }
  const event = buildEvent("filmstrip_DS796-.H757-C44-1998")

  await reportMissingFilmstripFrame(event)

  assert.equal(notice.options.name, "TurboFilmstripFrameMissing")
  assert.equal(notice.options.context.response_body, "<html>Unexpected response</html>")
  assert.equal(notice.options.context.response_body_truncated, false)
  assert.equal(notice.options.context.response_status, 200)
  assert.equal(notice.options.context.response_request_id, "request-id")
})

test("silently ignores a BIG-IP block page", async() => {
  let notified = false
  globalThis.Honeybadger = { notify: () => { notified = true } }
  const response = buildResponse("<html>Your support ID is: 123456789</html>")
  const event = buildEvent("filmstrip_DS796-.H757-C44-1998", response)

  await handleFilmstripFrameMissing(event)

  assert.equal(event.defaultPrevented, true)
  assert.equal(notified, false)
})

test("reports when the missing frame response body cannot be read", async() => {
  let notice
  globalThis.Honeybadger = { notify: (error, options) => { notice = { error, options } } }
  const response = buildResponse()
  response.clone = () => ({ text: async() => { throw new Error("body unavailable") } })

  await reportMissingFilmstripFrame(buildEvent("filmstrip_PR146-.H88-2009eb", response))

  assert.equal(notice.options.context.response_body, undefined)
  assert.equal(notice.options.context.response_body_read_error, "body unavailable")
})
