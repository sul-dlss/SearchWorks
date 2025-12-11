import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="citation-format"
export default class extends Controller {
  static targets = ["tab"]

  reveal(e) {
    const citationFormat = e.target.value
    this.tabTargets.forEach(tab => tab.hidden = true)
    this.element.querySelector("#" + citationFormat).hidden = false
  }
}
