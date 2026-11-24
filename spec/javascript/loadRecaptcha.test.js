import assert from "node:assert/strict"
import test from "node:test"

import loadRecaptcha, { resetRecaptchaLoads } from "../../app/javascript/recaptcha/loadRecaptcha.js"

const URL = "https://www.google.com/recaptcha/api.js?render=site-key"

const buildEnvironment = () => {
  const scripts = []
  const win = {}
  const doc = {
    createElement() {
      const listeners = {}
      const script = {
        addEventListener(type, callback) { listeners[type] = callback },
        remove() { scripts.splice(scripts.indexOf(script), 1) },
        fire(type) { listeners[type]() }
      }
      return script
    },
    head: { appendChild(script) { scripts.push(script) } }
  }
  const grecaptcha = { ready(callback) { callback() }, execute: async () => "token" }

  return { doc, win, scripts, grecaptcha }
}

test("loads the script once and resolves with grecaptcha when ready", async () => {
  resetRecaptchaLoads()
  const { doc, win, scripts, grecaptcha } = buildEnvironment()

  const first = loadRecaptcha(URL, { doc, win })
  const second = loadRecaptcha(URL, { doc, win })

  assert.equal(scripts.length, 1)
  assert.equal(scripts[0].src, URL)
  assert.equal(scripts[0].async, true)

  win.grecaptcha = grecaptcha
  scripts[0].fire("load")

  assert.equal(await first, grecaptcha)
  assert.equal(await second, grecaptcha)
})

test("uses grecaptcha without adding a script when it is already present", async () => {
  resetRecaptchaLoads()
  const { doc, win, scripts, grecaptcha } = buildEnvironment()
  win.grecaptcha = grecaptcha

  assert.equal(await loadRecaptcha(URL, { doc, win }), grecaptcha)
  assert.equal(scripts.length, 0)
})

test("rejects when the script fails to load and allows a retry", async () => {
  resetRecaptchaLoads()
  const { doc, win, scripts, grecaptcha } = buildEnvironment()

  const failed = loadRecaptcha(URL, { doc, win })
  scripts[0].fire("error")

  await assert.rejects(failed, /Unable to load reCAPTCHA/)
  assert.equal(scripts.length, 0)

  const retry = loadRecaptcha(URL, { doc, win })
  assert.equal(scripts.length, 1)
  win.grecaptcha = grecaptcha
  scripts[0].fire("load")

  assert.equal(await retry, grecaptcha)
})
