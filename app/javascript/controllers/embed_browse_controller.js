import { Controller } from "@hotwired/stimulus"
import PreviewContent from '../preview-content'
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
    this.item = $(this.element)
    this.viewportTarget = document.querySelector(this.viewportSelectorValue)
    this.galleryTarget = this.viewportTarget.querySelector('.gallery')
    this.embedContainer = $(this.galleryTarget)
    if (!this.hasContent()) {
      this.displayLink()
      PreviewContent.append(this.urlValue, this.embedContainer)
        .done((data) => {
          this.reorderPreviewElements();
          scrollOver(this.currentDocumentTarget(), this.galleryTarget)
        })
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
    const previewElements = this.embedContainer.find('.preview-container')
    $(this.viewportTarget).append(previewElements);
  }
}
