import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mini-mini-bento"
export default class extends Controller {
  static values = { url: String }
  static targets = ["count"]

  // triggered by mini-bento controller when it has data (or after this element is connected)
  receiveCount(count) {
    if (count < 1) return;

    this.countTarget.innerHTML = `${count.toLocaleString()} matches`
    this.element.classList.remove('d-none')
  }
}
