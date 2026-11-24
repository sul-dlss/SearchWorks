import { Controller } from "@hotwired/stimulus"
import loadRecaptcha from "../recaptcha/loadRecaptcha.js"

export default class extends Controller {
  // Target for the `RecaptchaComponent`, which contains the data attributes for action, siteKey & scriptUrl
  static targets = ["tags"]

  // Bound with `focusin->recaptcha#load:once` so reCAPTCHA starts loading as soon as someone
  // starts filling in the form, rather than on every page that happens to contain one.
  load() {
    const scriptUrl = this.scriptUrl()
    if (!scriptUrl) return Promise.resolve(undefined)

    return loadRecaptcha(scriptUrl).catch((error) => {
      console.error(error)
      return undefined
    })
  }

  async refresh(event) {
    // The recaptcha tags aren't always rendered (e.g., if a user is logged in).
    if (!this.isRecaptchaEnabled()) return

    event.preventDefault()
    await this.execute()

    if (this.isUsingTurbo(event)) {
      Turbo.navigator.submitForm(event.target)
    } else {
      event.target.submit()
    }
  }

  isRecaptchaEnabled() {
    return this.hasTagsTarget ? true : false
  }

  isUsingTurbo(event) {
    if (event.target.getAttribute("data-turbo") === "false") {
      return false
    }

    return typeof Turbo !== "undefined"
  }

  recaptchaElement() {
    const action = this.action().replace("_", "-")
    const recaptchaId = `g-recaptcha-response-data-${action}`
    return document.getElementById(recaptchaId)
  }

  action() {
    return this.tagsTarget.getAttribute("data-recaptcha-action-value")
  }

  siteKey() {
    return this.tagsTarget.getAttribute("data-recaptcha-site-key-value")
  }

  scriptUrl() {
    return this.hasTagsTarget ? this.tagsTarget.getAttribute("data-recaptcha-script-url-value") : null
  }

  async execute() {
    const recaptchaElement = this.recaptchaElement()
    if (!recaptchaElement) return

    // If the script can't be loaded (e.g. blocked), submit without a token and let the server reject it.
    const grecaptcha = await this.load()
    if (!grecaptcha) return

    const response = await grecaptcha.execute(this.siteKey(), { action: this.action() })
    if (response) recaptchaElement.value = response
  }
}
