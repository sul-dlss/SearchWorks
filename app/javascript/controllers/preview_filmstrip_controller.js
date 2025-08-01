import { Controller } from "@hotwired/stimulus"

// Filmstrip view for an image collection e.g. https://searchworks.stanford.edu/view/13156376
export default class extends Controller {
  static values = {
    url: String,
    id: String
  }

  static targets = [ "button" ]
  static outlets = ['preview']

  connect() {
    // NOTE: The filmstrip, viewport, prevew ,and closeBtn are outside of the controller.
    this.filmstrip = this.element.closest('.image-filmstrip');
    this.viewport = this.filmstrip.querySelector('.viewport');
  }

  updateButton(state) {
    if (state == 'open') {
      this.buttonTarget.classList.add('preview-open')
      this.buttonTarget.querySelector('.bi').classList.add('bi-chevron-up')
      this.buttonTarget.querySelector('.bi').classList.remove('bi-chevron-down')
      this.buttonTarget.ariaLabel = 'Hide preview'
      this
    } else if (this.buttonTarget.classList.contains('preview-open')) {
      this.buttonTarget.classList.remove('preview-open')
      this.buttonTarget.querySelector('.bi').classList.remove('bi-chevron-up')
      this.buttonTarget.querySelector('.bi').classList.add('bi-chevron-down')
      this.buttonTarget.ariaLabel = 'Show preview'
    }
  }

  togglePreview() {
    if (this.buttonTarget.classList.contains('preview-open')) {
      this.closePreview()
    } else {
      this.showPreview()
    }
  }

  showPreview() {
    this.updateButton('open')

    this.previewOutlet.load(this.idValue, this.urlValue)
    this.adjustPreviewMargins();
    this.attachPreviewEvents()
  }

  closePreview() {
    this.updateButton('closed')
    this.previewOutlet.close()
  }

  handlePreviewClose(event) {
    if (event.target != this.previewOutletElement) return;

    this.updateButton('closed')
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
