// Loads the Google reCAPTCHA v3 script on demand and resolves with `grecaptcha` once it is ready.
// Concurrent and repeated calls share a single script tag; a failed load can be retried.
const loads = new Map()

export default function loadRecaptcha(url, { doc = document, win = window } = {}) {
  if (!loads.has(url)) {
    const promise = new Promise((resolve, reject) => {
      const whenReady = () => win.grecaptcha.ready(() => resolve(win.grecaptcha))

      if (win.grecaptcha?.ready) {
        whenReady()
        return
      }

      const script = doc.createElement("script")
      script.src = url
      script.async = true
      script.addEventListener("load", whenReady)
      script.addEventListener("error", () => {
        loads.delete(url)
        script.remove()
        reject(new Error(`Unable to load reCAPTCHA from ${url}`))
      })
      doc.head.appendChild(script)
    })
    loads.set(url, promise)
  }

  return loads.get(url)
}

// Exposed for tests.
export function resetRecaptchaLoads() {
  loads.clear()
}
