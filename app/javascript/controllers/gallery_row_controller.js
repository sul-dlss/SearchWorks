import { Controller } from "@hotwired/stimulus"
import scrollOver from "../scroll-over"

// Connects to data-controller="gallery-row"
export default class extends Controller {
  static targets = [ "container" ]
  static outlets = [ "preview-embed-browse", "preview" ]
  static values = {
    currentDocumentClass: { type: String, default: 'current-document' }
  }

  scrollToCurrentDocument() {
    scrollOver(this.currentDocumentTarget(), this.containerTarget)
  }

  currentDocumentTarget() {
    return this.previewEmbedBrowseOutletElements.find(el => el.classList.contains(this.currentDocumentClassValue));
  }
}
