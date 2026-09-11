import assert from "node:assert/strict"
import test from "node:test"

import { configureHoneybadgerFilters, ignoreHoneybadgerNotice } from "../../app/javascript/honeybadger.js"

test("ignores an unhandled promise rejection with an empty object reason", () => {
  assert.equal(ignoreHoneybadgerNotice({
    name: "window.onunhandledrejection",
    message: "UnhandledPromiseRejectionWarning: {}"
  }), true)
})

test("ignores an unhandled promise rejection with no specified reason", () => {
  assert.equal(ignoreHoneybadgerNotice({
    name: "window.onunhandledrejection",
    message: "UnhandledPromiseRejectionWarning: Unspecified reason"
  }), true)
})

test("ignores CefSharp object binding promise rejections", () => {
  assert.equal(ignoreHoneybadgerNotice({
    name: "window.onunhandledrejection",
    message: "UnhandledPromiseRejectionWarning: Object Not Found Matching Id:2, MethodName:update, ParamCount:4"
  }), true)
  assert.equal(ignoreHoneybadgerNotice({
    name: "window.onunhandledrejection",
    message: "UnhandledPromiseRejectionWarning: Object Not Found Matching Id:15, MethodName:simulateEvent, ParamCount:2"
  }), true)
})

test("reports other object-not-found errors", () => {
  assert.equal(ignoreHoneybadgerNotice({
    name: "window.onunhandledrejection",
    message: "UnhandledPromiseRejectionWarning: Object Not Found Matching Id:2"
  }), false)
})

test("reports an unhandled promise rejection with actionable information", () => {
  assert.equal(ignoreHoneybadgerNotice({
    name: "window.onunhandledrejection",
    message: "UnhandledPromiseRejectionWarning: Failed to load availability"
  }), false)
})

test("continues to ignore Turnstile errors", () => {
  assert.equal(ignoreHoneybadgerNotice({ name: "TurnstileError", message: "Widget failed" }), true)
})

test("registers the notice filter with Honeybadger", () => {
  let filter
  const honeybadger = { beforeNotify(callback) { filter = callback } }

  configureHoneybadgerFilters(honeybadger)

  assert.equal(filter({
    name: "window.onunhandledrejection",
    message: "UnhandledPromiseRejectionWarning: {}"
  }), false)
  assert.equal(filter({ name: "TypeError", message: "Something broke" }), undefined)
})
