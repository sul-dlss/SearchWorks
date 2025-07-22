import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery-preview"
export default class extends Controller {
  static values = {
    actionsSelector: String,
    id: String,
    url: String,
    previewSelector: String
  }

  static targets = [ "button" ]

  static outlets = [ "gallery-preview" ]

  connect() {
    this.previewTarget = document.querySelector(this.previewSelectorValue)

    this.closeBtn = document.createElement('button')
    this.closeBtn.type = 'button'
    this.closeBtn.className = 'preview-close btn-close'
    this.closeBtn.setAttribute('aria-label', 'Close')
    this.closeBtn.innerHTML = '<span aria-hidden="true" class="visually-hidden">×</span>'
    this.arrow = document.createElement('div')
    this.arrow.className = 'preview-arrow'
    this.gallery = document.querySelectorAll('.gallery-document')
    this.reorderPreviewDivs()
    window.addEventListener('resize', () => this.reorderPreviewDivs())
  }

  showPreview() {
    this.previewTarget.classList.add('preview', 'd-block')
    this.previewTarget.classList.remove('d-none')
    this.previewTarget.innerHTML = `<turbo-frame src="${this.urlValue}" id="preview_${this.idValue}"></turbo-frame>`
    this.previewTarget.appendChild(this.closeBtn)

    this.appendPointer()

    this.buttonTarget.classList.add('preview-open', 'bi-chevron-up')
    this.adjustPreviewMargins()
    this.attachPreviewEvents()
  }

  adjustPreviewMargins() {
    // This is assuming the preview is styled for 100% width
    this.previewTarget.style.marginLeft = 0
    this.previewTarget.style.marginRight = 0
    const maxPreviewWidth = 800
    const galleryGapWidth = 16
    const galleryRect = this.element.getBoundingClientRect()
    const galleryDocumentWidth = galleryRect.width + galleryGapWidth
    const previewWidth = this.previewTarget.getBoundingClientRect().width
    const documentsOnRow = Math.floor(previewWidth/galleryDocumentWidth)
    const documentsRect = document.getElementById('documents').getBoundingClientRect()
    const leftBound = documentsRect.left
    const rightBound = leftBound + documentsRect.width
    const minMarginRight = Math.ceil(previewWidth - (documentsOnRow * galleryDocumentWidth) + galleryGapWidth)
    const galleryCenterDistanceFromLeftBound = (galleryRect.left + (galleryDocumentWidth / 2)) - leftBound
    const galleryCenterDistanceFromRightBound = rightBound - (galleryRect.left + (galleryDocumentWidth / 2))

    if (previewWidth <= maxPreviewWidth) {
      // Adjust the right margin so it matches the unused flex space at the end of the row
      this.previewTarget.style.marginRight = `${minMarginRight}px`
      this.movePointer(galleryCenterDistanceFromLeftBound)
      return
    }

    if (galleryCenterDistanceFromLeftBound <= (maxPreviewWidth/2)) {
      // If the center of the element is too close to the left to center, max the right margin
      const marginRight = Math.ceil(previewWidth - maxPreviewWidth)
      this.previewTarget.style.marginRight = `${marginRight}px`
      this.movePointer(galleryCenterDistanceFromLeftBound)
      return
    }

    if (galleryCenterDistanceFromRightBound <= (maxPreviewWidth/2)) {
      // If the center of the element is too close to the right to center, max the left margin
      const marginLeft = Math.ceil(previewWidth - maxPreviewWidth) - minMarginRight
      this.previewTarget.style.marginLeft = `${marginLeft}px`
      this.previewTarget.style.marginRight = `${minMarginRight}px`
      this.movePointer(galleryCenterDistanceFromLeftBound - marginLeft)
      return
    }

    // Otherwise we need to balance the left and right margins to center the preview
    const marginLeft = Math.ceil(galleryCenterDistanceFromLeftBound - (maxPreviewWidth / 2))
    const marginRight = Math.ceil(previewWidth - maxPreviewWidth - marginLeft)
    this.previewTarget.style.marginLeft = `${marginLeft}px`
    this.previewTarget.style.marginRight = `${marginRight}px`
    this.movePointer(galleryCenterDistanceFromLeftBound - marginLeft)
  }

  clamp(x, min, max) {
    return Math.min(Math.max(x, min), max)
  }

  appendPointer() {
    this.previewTarget.appendChild(this.arrow)
  }

  movePointer(targetCenter) {
    const pointerWidth = 21
    const arrowLeft = targetCenter - pointerWidth
    this.arrow.style.left = arrowLeft + 'px'
  }

  togglePreview(e) {
    if (this.previewOpen()){
      this.closePreview()
    } else {
      // Close the others
      this.galleryPreviewOutlets.forEach((tile) => {
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
      if (e.target === this.buttonTarget) {
        return true
      } else {
        return false
      }
    }
  }

  previewOpen(){
    return this.buttonTarget.classList.contains('preview-open')
  }

  attachPreviewEvents() {
    window.addEventListener('resize', () => {
      this.adjustPreviewMargins()
      this.movePointer()
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

  itemsPerRow() {
    const itemWidth = this.element.getBoundingClientRect().width + 16;
    const documentsWidth = document.getElementById('documents').getBoundingClientRect().width;
    return Math.floor(documentsWidth/itemWidth)
  }

  // Depending on how narrow the screen is, we may need to move the preview div location.
  reorderPreviewDivs() {
    const docId = this.previewTarget.dataset.documentId
    const galleryDocs = document.querySelectorAll('.gallery-document')
    const targetDoc = document.querySelector(`.gallery-document[data-document-id='${docId}']`)
    let previewIndex = Array.from(galleryDocs).indexOf(targetDoc) + 1

    const itemsPerRow = this.itemsPerRow()
    /*
    / If $itemsPerRow is NaN or 0 we should return here. If not we are going
    / to have a bad time with an infinite while loop. This only manifests
    / on the show page when using the "back" button to get back to a show
    / page using the browse nearby feature.
    /
    / Reproduction steps for NaN:
    / 1. visit https://searchworks.stanford.edu/view/2279186
    / 2. click on the bound-with link "Copy 1 bound with v. 5, no. 1. 36105026515499 (item id)"
    / 3. click the back button
    /
    */
    if (Number.isNaN(itemsPerRow) || itemsPerRow === 0) {
      return
    }

    if (this.arrow) {
      this.appendPointer()
    }

    while (previewIndex % itemsPerRow !== 0) {
      previewIndex++
    }
    if (previewIndex > galleryDocs.length) {
      previewIndex = galleryDocs.length
    }
    this.previewTarget.parentNode.removeChild(this.previewTarget)
    const galleryItem = this.gallery[(previewIndex-1)]
    galleryItem.parentNode.insertBefore(this.previewTarget, galleryItem.nextSibling)
  }
}
