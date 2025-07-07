import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="feedback-standalone"
export default class extends Controller {
  static targets = [ 'container' ]

  connect() {
    console.log("Feedback standalone")
  }

  hideForm() {
   this.containerTarget.classList.add('d-none')
  }
}
