import { Controller } from "@hotwired/stimulus"
import scrollOver from "../scroll-over"

// Connects to data-controller="embed-browse"
export default class extends Controller {
  static values = {
    viewportSelector: String,
    url: String,
    browseUrl: String,
    currentDoc: String
  }

  connect() {
    this.viewportTarget = document.querySelector(this.viewportSelectorValue)
    this.galleryTarget = this.viewportTarget.querySelector('.gallery')
    if (!this.hasContent()) {
      this.displayLink()
      this.galleryTarget.addEventListener('turbo:frame-load', () => {
        this.reorderPreviewElements();
        scrollOver(this.currentDocumentTarget(), this.galleryTarget)
      }, true)
    }
  }

  docs() {
    return this.viewportTarget.querySelectorAll('.gallery-document')
  }

  hasContent() {
    return this.docs().length !== 0
  }

  currentDocumentTarget() {
    return this.viewportTarget
      .querySelector(`.gallery-document[data-doc-id="${this.currentDocValue}"]`)
  }

  displayLink() {
    const linkViewFullPage = document.querySelector('.view-full-page a')
    linkViewFullPage.href = this.browseUrlValue
    linkViewFullPage.hidden = false
  }

  reorderPreviewElements() {
    const previewElements = this.galleryTarget.querySelectorAll('.preview-container')

    // Append each preview element to the viewport target
    previewElements.forEach(element => {
      this.viewportTarget.appendChild(element)
    })
  }
}
