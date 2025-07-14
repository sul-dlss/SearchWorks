import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="feedback-standalone"
export default class extends Controller {
  static targets = [ 'container' ]

  hideForm() {
   this.containerTarget.classList.add('d-none')
  }
}
