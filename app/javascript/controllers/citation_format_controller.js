import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="citation-format"
export default class extends Controller {
  static targets = ['panel']

  reveal(e) {
    const citationFormat = e.target.value
    this.panelTargets.forEach(panel => panel.hidden = true)
    this.element.querySelector(`#citation-format-${citationFormat}`).hidden = false
  }
}
