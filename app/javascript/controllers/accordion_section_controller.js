import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["snippet", "details", "button"]

  toggle() {
    this.buttonTarget.classList.toggle('open')
    if (this.buttonTarget.classList.contains('open')) {
      this.detailsTarget.style.display = 'block'
      this.snippetTarget.style.display = 'none'
      this.buttonTarget.setAttribute('aria-expanded', 'true')
    } else {
      this.detailsTarget.style.display = 'none'
      this.snippetTarget.style.display = 'block'
      this.buttonTarget.setAttribute('aria-expanded', 'false')
    }
  }
}
