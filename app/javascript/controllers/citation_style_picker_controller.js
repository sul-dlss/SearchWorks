import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="citation-style-picker"
export default class extends Controller {
  static targets = ["select", "tab"]

  switch() {
    this.tabTargets.forEach(tab => tab.hidden = true )
    this.element.querySelector(`#${this.selectTarget.value}`).hidden = false
  }
}
