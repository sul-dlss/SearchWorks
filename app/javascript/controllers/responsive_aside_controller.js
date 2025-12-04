import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "responsive", "default"]

  connect() {
    this.lastState = null
    this.moveContentIfNeeded()
  }

  moveContentIfNeeded() {
    if (!this.hasResponsiveTarget || !this.hasContentTarget) return

    const stateChanged = !this.lastState || this.responsiveTargetVisible !== this.lastState

    if (!stateChanged) return

    this.lastState = this.responsiveTargetVisible

    if (this.responsiveTargetVisible) {
      this.responsiveTarget.appendChild(this.contentTarget)
    } else {
      this.defaultTarget.appendChild(this.contentTarget)
    }
  }

  get responsiveTargetVisible() {
    return this.hasResponsiveTarget && this.responsiveTarget.checkVisibility && this.responsiveTarget.checkVisibility()
  }
}
