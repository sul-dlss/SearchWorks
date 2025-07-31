import { Controller } from "@hotwired/stimulus"

// Filmstrip view for an image collection e.g. https://searchworks.stanford.edu/view/13156376
export default class extends Controller {
  static values = {
    url: String,
    id: String
  }

  static outlets = ['preview']

  connect() {
    this.triggerBtn = document.createElement('button')
    this.triggerBtn.classList.add('btn', 'preview-trigger-btn', 'preview-opacity')
    this.triggerBtn.ariaLabel = 'Show preview'
    this.triggerBtn.dataset.action = 'click->preview-filmstrip#togglePreview'
    this.triggerBtn.innerHTML = '<span class="bi-chevron-down small"></span>'

    // NOTE: The filmstrip, viewport, prevew ,and closeBtn are outside of the controller.
    this.filmstrip = this.element.closest('.image-filmstrip');
    this.viewport = this.filmstrip.querySelector('.viewport');
    this.appendTriggers()
  }

  appendTriggers() {
    this.element.append(this.triggerBtn);
  }

  togglePreview() {
    if (this.triggerBtn.classList.contains('preview-open')) {
      this.closePreview()
    } else {
      this.showPreview()
    }
  }

  toggleButtonClosed(button) {
    button.classList.remove('preview-open')
    this.triggerBtn.ariaLabel = 'Hide preview'
    button.innerHTML = '<span class="bi-chevron-down small"></span>'
  }

  showPreview() {
    const prevOpenButton = document.querySelector('.preview-open')
    if (prevOpenButton) this.toggleButtonClosed(prevOpenButton)
    this.triggerBtn.classList.add('preview-open')
    this.triggerBtn.ariaLabel = 'Hide preview'
    this.triggerBtn.innerHTML = '<span class="bi-chevron-up small"></span>'

    this.previewOutlet.load(this.idValue, this.urlValue)
    this.adjustPreviewMargins();
    this.attachPreviewEvents()
  }

  closePreview() {
    this.toggleButtonClosed(this.triggerBtn);
    this.previewOutlet.close()
  }

  handlePreviewClose(event) {
    if (event.target != this.previewOutletElement) return;

    this.toggleButtonClosed(this.triggerBtn);
  }

  adjustPreviewMargins() {
    const maxPreviewWidth = this.viewport.getBoundingClientRect().width;
    const galleryGapWidth = 8
    const galleryRect = this.element.getBoundingClientRect()
    const previewRect = this.previewOutletElement.getBoundingClientRect()
    const galleryDocumentWidth = galleryRect.width + galleryGapWidth
    const previewWidth = previewRect.width
    const leftBound = previewRect.left
    const rightBound = leftBound + previewWidth
    const minMargin = 8 // Not tied to anything, it just looks nice and leaves space for the drop shadow.
    const galleryCenterDistanceFromLeftBound = (galleryRect.left + (galleryDocumentWidth / 2)) - leftBound
    const galleryCenterDistanceFromRightBound = rightBound - (galleryRect.left + (galleryDocumentWidth / 2))

    if (previewWidth <= maxPreviewWidth) {
      // The potential max width of the preview is smaller than our specified max width, so add our minimum padding.
      this.movePointer(galleryCenterDistanceFromLeftBound, leftBound, leftBound + previewWidth - (2 * minMargin))
      return
    }

    if (galleryCenterDistanceFromLeftBound <= (maxPreviewWidth/2)) {
      this.movePointer(galleryCenterDistanceFromLeftBound, leftBound, leftBound + maxPreviewWidth)
      return
    }

    if (galleryCenterDistanceFromRightBound <= (maxPreviewWidth/2)) {
      // If the center of the element is too close to the right to center, max the left margin
      const marginLeft = Math.ceil(previewWidth - maxPreviewWidth) - minMargin
      this.movePointer(galleryCenterDistanceFromLeftBound - marginLeft, leftBound, leftBound + maxPreviewWidth)
      return
    }

    // Otherwise we need to balance the left and right margins to center the preview
    const marginLeft = Math.ceil(galleryCenterDistanceFromLeftBound - (maxPreviewWidth / 2))
    this.movePointer(galleryCenterDistanceFromLeftBound - marginLeft, leftBound, leftBound + maxPreviewWidth)
  }

  movePointer(targetCenter, leftBound, rightBound) {
    const pointerWidth = 21
    const arrowLeft = targetCenter - pointerWidth

    if (arrowLeft > 0 && leftBound + targetCenter < rightBound) {
      this.arrow.style.left = arrowLeft + 'px'
      this.arrow.classList.add('d-block')
      this.arrow.classList.remove('d-none')
    } else {
      this.arrow.classList.add('d-none')
      this.arrow.classList.remove('d-block')
    }
  }

  get arrow() {
    return this.previewOutlet.arrowTarget;
  }

  attachPreviewEvents() {
    const scrollContainer = this.viewport
    if (scrollContainer) {
      scrollContainer.addEventListener('scroll', () => {
        this.adjustPreviewMargins()
      })
    }
    window.addEventListener('resize', () => {
      this.adjustPreviewMargins()
    })
  }
}
