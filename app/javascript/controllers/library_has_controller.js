import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="library-has"
export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.updateDisplay()
  }

  updateDisplay() {
    if (this.requestButtonExists()) {
      // If the request button exists, we want the library popover link
      // to wrap to the next line and be left aligned
      this.containerTarget.classList.remove('justify-content-end')
      this.containerTarget.classList.add('w-100')
    }
  }

  requestButtonExists() {
    return this.element.querySelector('a.location-request-link') != null
  }
}
