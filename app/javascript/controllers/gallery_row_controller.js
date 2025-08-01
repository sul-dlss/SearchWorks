import { Controller } from "@hotwired/stimulus"
import scrollOver from "../scroll-over"

// Connects to data-controller="gallery-row"
export default class extends Controller {
  static targets = [ "container" ]
  static outlets = [ "gallery-card", "preview" ]
  static values = {
    currentDocumentClass: { type: String, default: 'current-document' },
    maxPreviewWidth: { type: Number, default: -1 }
  }

  scrollToCurrentDocument() {
    scrollOver(this.currentDocumentTarget(), this.containerTarget)
  }

  currentDocumentTarget() {
    return this.galleryCardOutletElements.find(el => el.classList.contains(this.currentDocumentClassValue));
  }

  setCurrentPreview(event) {
    this.currentPreview = event.target;

    this.galleryCardOutlets.forEach((tile) => {
      if (tile.element === event.target) return;

      tile.updateButton('closed');
    });

    this.adjustPreviewMargins();
  }

  get previewContainer() {
    return this.galleryCardOutletElement.parentElement;
  }

  adjustPreviewMargins() {
    if (!this.currentPreview) return;

    // This is assuming the preview is styled for 100% width
    this.previewOutletElement.style.marginLeft = 0
    this.previewOutletElement.style.marginRight = 0
    const maxPreviewWidth = this.maxPreviewWidthValue;
    const galleryRect = this.currentPreview.getBoundingClientRect()
    const previewRect = this.previewOutletElement.getBoundingClientRect()
    const galleryDocumentWidth = this.previewContainer.getBoundingClientRect().width / this.galleryCardOutlets.length;
    const previewWidth = previewRect.width
    const leftBound = previewRect.left
    const rightBound = leftBound + previewWidth
    const minMargin = 8 // Not tied to anything, it just looks nice and leaves space for the drop shadow.
    const galleryCenterDistanceFromLeftBound = (galleryRect.left + (galleryDocumentWidth / 2)) - leftBound
    const galleryCenterDistanceFromRightBound = rightBound - (galleryRect.left + (galleryDocumentWidth / 2))

    if (maxPreviewWidth < 0 || previewWidth <= maxPreviewWidth) {
      // The potential max width of the preview is smaller than our specified max width, so add our minimum padding.
      this.previewOutletElement.style.marginLeft = `${minMargin}px`
      this.previewOutletElement.style.marginRight = `${minMargin}px`
      this.movePointer(galleryCenterDistanceFromLeftBound, leftBound, leftBound + previewWidth - (2 * minMargin))
      return
    }

    if (galleryCenterDistanceFromLeftBound <= (maxPreviewWidth/2)) {
      // If the center of the element is too close to the left to center, max the right margin
      const marginRight = Math.ceil(previewWidth - maxPreviewWidth) - minMargin
      this.previewOutletElement.style.marginLeft = `${minMargin}px`
      this.previewOutletElement.style.marginRight = `${marginRight}px`
      this.movePointer(galleryCenterDistanceFromLeftBound, leftBound, leftBound + maxPreviewWidth)
      return
    }

    if (galleryCenterDistanceFromRightBound <= (maxPreviewWidth/2)) {
      // If the center of the element is too close to the right to center, max the left margin
      const marginLeft = Math.ceil(previewWidth - maxPreviewWidth) - minMargin
      this.previewOutletElement.style.marginLeft = `${marginLeft}px`
      this.previewOutletElement.style.marginRight = `${minMargin}px`
      this.movePointer(galleryCenterDistanceFromLeftBound - marginLeft, leftBound, leftBound + maxPreviewWidth)
      return
    }

    // Otherwise we need to balance the left and right margins to center the preview
    const marginLeft = Math.ceil(galleryCenterDistanceFromLeftBound - (maxPreviewWidth / 2))
    const marginRight = Math.ceil(previewWidth - maxPreviewWidth - marginLeft)
    this.previewOutletElement.style.marginLeft = `${marginLeft}px`
    this.previewOutletElement.style.marginRight = `${marginRight}px`
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
}
