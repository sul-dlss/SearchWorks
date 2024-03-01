import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="long-table-toggle"
export default class extends Controller {
  static outlets = [ "long-table" ]
  static targets = [ "expandButton", "collapseButton" ]

  connect() {
    this.collapseButtonTarget.hidden = true
  }

  expand() {
    this.expandButtonTarget.hidden = true
    this.collapseButtonTarget.hidden = false

    this.longTableOutlet.expand()
  }

  collapse() {
    this.expandButtonTarget.hidden = false
    this.collapseButtonTarget.hidden = true

    this.longTableOutlet.collapse()
  }
}
