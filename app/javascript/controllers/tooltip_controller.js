import { Controller } from "@hotwired/stimulus"
import { createPopper }  from '@popperjs/core'

// Must be instantiated on an element with an aria-label attribute
export default class extends Controller {
  connect () {
    this.tooltip = document.createElement("div")
    this.tooltip.classList.add('tooltip')
    this.tooltip.innerHTML = this.element.getAttribute('aria-label')
    this.tooltip.ariaHidden = 'true'
    this.element.appendChild(this.tooltip)

    this.popperInstance = createPopper(this.element, this.tooltip)
  }

  show() {
    this.tooltip.classList.add('show')
    this.popperInstance.update()
  }

  updatePopper() {
    this.tooltip.innerHTML = this.element.getAttribute('aria-label')
    this.popperInstance.update()
  }

  hide() {
      this.tooltip.classList.remove('show')
  }
}
