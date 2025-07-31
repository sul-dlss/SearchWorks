import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery-preview"
export default class extends Controller {
  static values = {
    id: String,
    url: String
  }

  static targets = [ "button" ]

  static outlets = [ "gallery-preview", "preview" ]

  connect() {
    this.gallery = document.querySelectorAll('.gallery-document')
    this.reorderPreviewDivs()
    window.addEventListener('resize', () => this.reorderPreviewDivs())
  }

  showPreview() {
    this.previewOutlet.load(this.idValue, this.urlValue)

    this.buttonTarget.classList.add('preview-open', 'bi-chevron-up')
    this.attachPreviewEvents()
    this.adjustPreviewMargins()
  }

  adjustPreviewMargins() {
    // This is assuming the preview is styled for 100% width
    this.previewOutletElement.style.marginLeft = 0
    this.previewOutletElement.style.marginRight = 0
    const maxPreviewWidth = 800
    const galleryGapWidth = 16
    const galleryRect = this.element.getBoundingClientRect()
    const galleryDocumentWidth = galleryRect.width + galleryGapWidth
    const previewWidth = this.previewOutletElement.getBoundingClientRect().width
    const documentsOnRow = Math.floor(previewWidth/galleryDocumentWidth)
    const documentsRect = document.getElementById('documents').getBoundingClientRect()
    const leftBound = documentsRect.left
    const rightBound = leftBound + documentsRect.width
    const minMarginRight = Math.ceil(previewWidth - (documentsOnRow * galleryDocumentWidth) + galleryGapWidth)
    const galleryCenterDistanceFromLeftBound = (galleryRect.left + (galleryDocumentWidth / 2)) - leftBound
    const galleryCenterDistanceFromRightBound = rightBound - (galleryRect.left + (galleryDocumentWidth / 2))

    if (previewWidth <= maxPreviewWidth) {
      // Adjust the right margin so it matches the unused flex space at the end of the row
      this.previewOutletElement.style.marginRight = `${minMarginRight}px`
      this.movePointer(galleryCenterDistanceFromLeftBound)
      return
    }

    if (galleryCenterDistanceFromLeftBound <= (maxPreviewWidth/2)) {
      // If the center of the element is too close to the left to center, max the right margin
      const marginRight = Math.ceil(previewWidth - maxPreviewWidth)
      this.previewOutletElement.style.marginRight = `${marginRight}px`
      this.movePointer(galleryCenterDistanceFromLeftBound)
      return
    }

    if (galleryCenterDistanceFromRightBound <= (maxPreviewWidth/2)) {
      // If the center of the element is too close to the right to center, max the left margin
      const marginLeft = Math.ceil(previewWidth - maxPreviewWidth) - minMarginRight
      this.previewOutletElement.style.marginLeft = `${marginLeft}px`
      this.previewOutletElement.style.marginRight = `${minMarginRight}px`
      this.movePointer(galleryCenterDistanceFromLeftBound - marginLeft)
      return
    }

    // Otherwise we need to balance the left and right margins to center the preview
    const marginLeft = Math.ceil(galleryCenterDistanceFromLeftBound - (maxPreviewWidth / 2))
    const marginRight = Math.ceil(previewWidth - maxPreviewWidth - marginLeft)
    this.previewOutletElement.style.marginLeft = `${marginLeft}px`
    this.previewOutletElement.style.marginRight = `${marginRight}px`
    this.movePointer(galleryCenterDistanceFromLeftBound - marginLeft)
  }

  clamp(x, min, max) {
    return Math.min(Math.max(x, min), max)
  }

  movePointer(targetCenter) {
    const pointerWidth = 21
    const arrowLeft = targetCenter - pointerWidth
    this.previewOutlet.arrowTarget.style.left = arrowLeft + 'px'
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

  previewOpen(){
    return this.buttonTarget.classList.contains('preview-open')
  }

  attachPreviewEvents() {
    window.addEventListener('resize', () => {
      this.adjustPreviewMargins()
      this.movePointer()
    })
  }

  closePreview() {
    this.previewOutlet.close()
  }

  handlePreviewClosed(event) {
    if (event.target != this.previewOutletElement) return;

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
    const docId = this.previewOutletElement.dataset.documentId
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

    while (previewIndex % itemsPerRow !== 0) {
      previewIndex++
    }
    if (previewIndex > galleryDocs.length) {
      previewIndex = galleryDocs.length
    }

    const galleryItem = this.gallery[(previewIndex-1)]
    galleryItem.parentNode.insertBefore(this.previewOutletElement, galleryItem.nextSibling)
  }
}
