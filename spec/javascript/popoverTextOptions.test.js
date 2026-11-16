import assert from "node:assert/strict"
import test from "node:test"

import popoverTextOptions from "../../app/javascript/popoverTextOptions.js"

const buildElement = (attributes) => ({
  getAttribute(name) {
    return Object.hasOwn(attributes, name) ? attributes[name] : null
  }
})

test("keeps JSON-like content and title as strings", () => {
  const element = buildElement({ "data-bs-title": "1932", "data-bs-content": "[v.1-10], [1932]" })

  assert.deepEqual(popoverTextOptions(element), { title: "1932", content: "[v.1-10], [1932]" })
})

test("keeps content that would parse as a JSON array as a string", () => {
  const element = buildElement({ "data-bs-content": "[1932]" })

  assert.deepEqual(popoverTextOptions(element), { content: "[1932]" })
})

test("omits options whose attributes are absent", () => {
  assert.deepEqual(popoverTextOptions(buildElement({})), {})
})
