import { Controller } from "@hotwired/stimulus"
import { createPopper }  from '@popperjs/core'

// Must be instantiated on an element with a data-tooltip OR an aria-label attribute
export default class extends Controller {
  connect () {
    this.tooltip = document.createElement("div")
    this.tooltip.classList.add('tooltip')
    this.tooltip.innerHTML = this.tooltipText()
    this.tooltip.ariaHidden = 'true'
    this.element.appendChild(this.tooltip)

    this.popperInstance = createPopper(this.element, this.tooltip)
  }

  show() {
    this.tooltip.classList.add('show')
    this.popperInstance.update()
  }

  updatePopper() {
    this.tooltip.innerHTML = this.tooltipText()
    this.popperInstance.update()
  }

  tooltipText() {
    return this.element.getAttribute('data-tooltip') || this.element.getAttribute('aria-label')
  }

  hide() {
      this.tooltip.classList.remove('show')
  }
}
