import { Controller } from "@hotwired/stimulus"
import { computePosition, autoUpdate } from "@floating-ui/dom"

// Must be instantiated on an element with a data-tooltip OR an aria-label attribute
export default class extends Controller {
  connect() {
    this.tooltip = document.createElement("div")
    this.tooltip.classList.add("tooltip")
    this.tooltip.innerHTML = this.tooltipText()
    this.tooltip.ariaHidden = "true"
    Object.assign(this.tooltip.style, { position: "absolute", left: "0", top: "0" })
    this.element.appendChild(this.tooltip)
  }

  disconnect() {
    this.stopAutoUpdate()
  }

  show() {
    this.tooltip.classList.add("show")
    this.stopAutoUpdate()
    this.cleanup = autoUpdate(this.element, this.tooltip, () => this.updatePosition())
  }

  updatePopper() {
    this.tooltip.innerHTML = this.tooltipText()
    this.updatePosition()
  }

  async updatePosition() {
    const { x, y } = await computePosition(this.element, this.tooltip)
    Object.assign(this.tooltip.style, { left: `${x}px`, top: `${y}px` })
  }

  tooltipText() {
    return this.element.dataset.tooltip || this.element.ariaLabel
  }

  hide() {
    this.tooltip.classList.remove("show")
    this.stopAutoUpdate()
  }

  stopAutoUpdate() {
    if (this.cleanup) this.cleanup()
    this.cleanup = null
  }
}
