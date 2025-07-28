import { Controller } from "@hotwired/stimulus"

// Controls a single tile in the browse nearby ribbon
export default class extends Controller {
  static values = {
    actionsSelector: String,
    id: String,
    url: String,
    previewSelector: String
  }
  static targets = [ "button" ]
  static outlets = [ "preview-embed-browse" ]

  connect() {
    this.previewTarget = document.querySelector(this.previewSelectorValue)
    this.closeBtn = document.createElement('button')
    this.closeBtn.type = 'button'
    this.closeBtn.className = 'preview-close btn-close'
    this.closeBtn.setAttribute('aria-label', 'Close')
    this.closeBtn.innerHTML = '<span aria-hidden="true" class="visually-hidden">×</span>'
    this.arrow = document.createElement('div')
    this.arrow.className = 'preview-arrow'
  }

  showPreview() {
    this.previewTarget.classList.add('preview', 'd-block')
    this.previewTarget.classList.remove('d-none')
    this.previewTarget.innerHTML = `<turbo-frame src="${this.urlValue}" id="preview_${this.idValue}"></turbo-frame>`
    this.previewTarget.appendChild(this.closeBtn)
    this.appendPointer(this.previewTarget)
    this.buttonTarget.classList.add('preview-open', 'bi-chevron-up')
    this.attachPreviewEvents()
    this.hideDocumentActions()
    this.adjustPreviewMargins()
  }

  adjustPreviewMargins() {
    // This is assuming the preview is styled for 100% width
    this.previewTarget.style.marginLeft = 0
    this.previewTarget.style.marginRight = 0
    const maxPreviewWidth = 800
    const galleryGapWidth = 16
    const galleryRect = this.element.getBoundingClientRect()
    const previewRect = this.previewTarget.getBoundingClientRect()
    const galleryDocumentWidth = galleryRect.width + galleryGapWidth
    const previewWidth = previewRect.width
    const leftBound = previewRect.left
    const rightBound = leftBound + previewWidth
    const minMargin = 8 // Not tied to anything, it just looks nice and leaves space for the drop shadow.
    const galleryCenterDistanceFromLeftBound = (galleryRect.left + (galleryDocumentWidth / 2)) - leftBound
    const galleryCenterDistanceFromRightBound = rightBound - (galleryRect.left + (galleryDocumentWidth / 2))

    if (previewWidth <= maxPreviewWidth) {
      // The potential max width of the preview is smaller than our specified max width, so add our minimum padding.
      this.previewTarget.style.marginLeft = `${minMargin}px`
      this.previewTarget.style.marginRight = `${minMargin}px`
      this.movePointer(galleryCenterDistanceFromLeftBound, leftBound, leftBound + previewWidth - (2 * minMargin))
      return
    }

    if (galleryCenterDistanceFromLeftBound <= (maxPreviewWidth/2)) {
      // If the center of the element is too close to the left to center, max the right margin
      const marginRight = Math.ceil(previewWidth - maxPreviewWidth) - minMargin
      this.previewTarget.style.marginLeft = `${minMargin}px`
      this.previewTarget.style.marginRight = `${marginRight}px`
      this.movePointer(galleryCenterDistanceFromLeftBound, leftBound, leftBound + maxPreviewWidth)
      return
    }

    if (galleryCenterDistanceFromRightBound <= (maxPreviewWidth/2)) {
      // If the center of the element is too close to the right to center, max the left margin
      const marginLeft = Math.ceil(previewWidth - maxPreviewWidth) - minMargin
      this.previewTarget.style.marginLeft = `${marginLeft}px`
      this.previewTarget.style.marginRight = `${minMargin}px`
      this.movePointer(galleryCenterDistanceFromLeftBound - marginLeft, leftBound, leftBound + maxPreviewWidth)
      return
    }

    // Otherwise we need to balance the left and right margins to center the preview
    const marginLeft = Math.ceil(galleryCenterDistanceFromLeftBound - (maxPreviewWidth / 2))
    const marginRight = Math.ceil(previewWidth - maxPreviewWidth - marginLeft)
    this.previewTarget.style.marginLeft = `${marginLeft}px`
    this.previewTarget.style.marginRight = `${marginRight}px`
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

  appendPointer(target) {
    target.appendChild(this.arrow)

    const maxLeft = target.offsetWidth - this.arrow.offsetWidth - 1
    let arrowLeft = parseInt(this.element.getBoundingClientRect().left + (this.element.offsetWidth / 2) - target.offsetLeft)

    if (arrowLeft < 0) arrowLeft = 0
    if (arrowLeft > maxLeft) arrowLeft = maxLeft

    this.arrow.style.left = arrowLeft + 'px'
  }

  togglePreview(e) {
    if (this.previewOpen()){
      this.closePreview()
    } else {
      // Close the others
      this.previewEmbedBrowseOutlets.forEach((tile) => {
        if (tile !== this) {
          tile.closePreview()
        }
      })

      this.showPreview()

    }
  }

  currentPreview(e){
    // Check if we're clicking in a preview
    if (e.target.closest('.preview-container')){
      return true
    } else {
      return e.target === this.buttonTarget
    }
  }

  previewOpen(){
    return this.buttonTarget.classList.contains('preview-open')
  }

  scrollContainerTarget() {
    const container = this.previewTarget.closest('.embed-callnumber-browse-container')
    if (!container) return null
    return container.querySelector('.embedded-items')
  }

  attachPreviewEvents() {
    const scrollContainer = this.scrollContainerTarget()
    if (scrollContainer) {
      scrollContainer.addEventListener('scroll', () => {
        this.adjustPreviewMargins()
      })
    }
    window.addEventListener('resize', () => {
      this.adjustPreviewMargins()
    })
    this.previewTarget.addEventListener('turbo:frame-load', () => {
      this.hideDocumentActions()
    })
    this.closeBtn.addEventListener('click', () => {
      this.closePreview()
    })
  }

  hideDocumentActions() {
    const actionsElement = this.previewTarget.querySelector(this.actionsSelectorValue)
    if (actionsElement) {
      actionsElement.classList.remove('d-flex')
      actionsElement.classList.add('d-none')
    }
  }

  closePreview() {
    this.previewTarget.classList.remove('preview', 'd-block')
    this.previewTarget.classList.add('d-none')
    this.buttonTarget.classList.remove('preview-open', 'bi-chevron-up')
    this.buttonTarget.classList.add('bi-chevron-down')
  }
}
