import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="browse-related-items"
export default class extends Controller {
  static targets = [ 'viewport' ]
  static values = {
    start: String
  }

  connect() {
    this.markCurrentDocument()
  }

  currentDocumentTarget() {
    return this.viewportTarget
      .querySelector(`.gallery-document[data-doc-id="${this.startValue}"]`)
  }

  markCurrentDocument() {
    if (!this.startValue) return

    const currentDocument = this.currentDocumentTarget()
    if (currentDocument)
      currentDocument.classList.add('current-document')
  }
}
