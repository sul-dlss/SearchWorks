import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "showButton", "hideButton"]

  showPreview() {
    this.previewTarget.classList.add('show')
    this.showButtonTarget.hidden = true
    this.hideButtonTarget.hidden = false
  }

  closePreview() {
    this.previewTarget.classList.remove('show')
    this.showButtonTarget.hidden = false
    this.hideButtonTarget.hidden = true
  }
}
