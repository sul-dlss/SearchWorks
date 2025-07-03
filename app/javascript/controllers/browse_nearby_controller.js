import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="browse-nearby"
export default class extends Controller {
  static targets = [ "tabs" ]

  connect() {
    this.addActiveClasses(this.tabsTarget.querySelector('button.active'))
  }

  markActive(event) {
    this.addActiveClasses(event.target)
    this.removeActiveClasses(event.relatedTarget)
  }

  addActiveClasses(element) {
    if (element) element.classList.add('bi', 'bi-check2')
  }

  removeActiveClasses(element) {
    if (element) element.classList.remove('bi', 'bi-check2')
  }
}
