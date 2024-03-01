import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="long-list"
// This hides any items marked as hideable when toggled
export default class extends Controller {
  static targets = [ "expandButton", "collapseButton", "hideable" ]

  connect() {
    this.collapse()
    this.collapseButtonTarget.hidden = true
  }

  expand() {
    this.expandButtonTarget.hidden = true
    this.collapseButtonTarget.hidden = false
    this.hideableTargets.forEach((childElement) => childElement.hidden = false)
  }

  collapse() {
    this.expandButtonTarget.hidden = false
    this.collapseButtonTarget.hidden = true
    this.hideableTargets.forEach((childElement) => childElement.hidden = true)
  }
}
