import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery-layout"
export default class extends Controller {
  static outlets = ["gallery-card"]
  static values = {
    itemsPerRow: { type: Number, default: 0 }
  }

  connect() {
    this.reorderPreviewDivs()
  }

  handlePreviewShow(event) {
    this.currentGalleryCard = this.galleryCardOutlets.find((outlet) => outlet.element == event.target)

    this.galleryCardOutlets.forEach((tile) => {
      if (tile.element === event.target) return

      if (tile.previewOpen()) tile.closePreview()
    })


    this.adjustPreviewMargins()
  }

  adjustPreviewMargins() {
    if (!this.currentGalleryCard) return

    // This is assuming the preview is styled for 100% width
    this.currentGalleryCard.previewOutletElement.style.marginLeft = 0
    this.currentGalleryCard.previewOutletElement.style.marginRight = 0
    const maxPreviewWidth = 800
    const galleryGapWidth = 16
    const galleryRect = this.currentGalleryCard.element.getBoundingClientRect()
    const galleryDocumentWidth = galleryRect.width + galleryGapWidth
    const previewWidth = this.currentGalleryCard.previewOutletElement.getBoundingClientRect().width
    const documentsOnRow = Math.floor(previewWidth / galleryDocumentWidth)
    const documentsRect = this.element.getBoundingClientRect()
    const leftBound = documentsRect.left
    const rightBound = leftBound + documentsRect.width
    const minMarginRight = Math.ceil(previewWidth - (documentsOnRow * galleryDocumentWidth) + galleryGapWidth)
    const galleryCenterDistanceFromLeftBound = (galleryRect.left + (galleryDocumentWidth / 2)) - leftBound
    const galleryCenterDistanceFromRightBound = rightBound - (galleryRect.left + (galleryDocumentWidth / 2))

    if (previewWidth <= maxPreviewWidth) {
      // Adjust the right margin so it matches the unused flex space at the end of the row
      this.currentGalleryCard.previewOutletElement.style.marginRight = `${minMarginRight}px`
      this.movePointer(galleryCenterDistanceFromLeftBound)
      return
    }

    if (galleryCenterDistanceFromLeftBound <= (maxPreviewWidth / 2)) {
      // If the center of the element is too close to the left to center, max the right margin
      const marginRight = Math.ceil(previewWidth - maxPreviewWidth)
      this.currentGalleryCard.previewOutletElement.style.marginRight = `${marginRight}px`
      this.movePointer(galleryCenterDistanceFromLeftBound)
      return
    }

    if (galleryCenterDistanceFromRightBound <= (maxPreviewWidth / 2)) {
      // If the center of the element is too close to the right to center, max the left margin
      const marginLeft = Math.ceil(previewWidth - maxPreviewWidth) - minMarginRight
      this.currentGalleryCard.previewOutletElement.style.marginLeft = `${marginLeft}px`
      this.currentGalleryCard.previewOutletElement.style.marginRight = `${minMarginRight}px`
      this.movePointer(galleryCenterDistanceFromLeftBound - marginLeft)
      return
    }

    // Otherwise we need to balance the left and right margins to center the preview
    const marginLeft = Math.ceil(galleryCenterDistanceFromLeftBound - (maxPreviewWidth / 2))
    const marginRight = Math.ceil(previewWidth - maxPreviewWidth - marginLeft)
    this.currentGalleryCard.previewOutletElement.style.marginLeft = `${marginLeft}px`
    this.currentGalleryCard.previewOutletElement.style.marginRight = `${marginRight}px`
    this.movePointer(galleryCenterDistanceFromLeftBound - marginLeft)
  }

  movePointer(targetCenter) {
    const pointerWidth = 21
    const arrowLeft = targetCenter - pointerWidth
    this.currentGalleryCard.previewOutlet.arrowTarget.style.left = arrowLeft + "px"
  }

  itemsPerRow() {
    // the item, plus the gap between items
    const itemWidth = this.galleryCardOutletElement.getBoundingClientRect().width + 16

    // the container, plus the left and right item gap (accounting for the beginning + end of the row)
    const documentsWidth = this.element.getBoundingClientRect().width + 16
    return Math.floor(documentsWidth / itemWidth)
  }

  // Depending on how narrow the screen is, we may need to move the preview div location.
  reorderPreviewDivs() {
    const itemsPerRow = this.itemsPerRow()

    if (itemsPerRow === this.itemsPerRowValue) return

    this.itemsPerRowValue = itemsPerRow

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

    let buffer = []
    this.galleryCardOutlets.forEach((tile, index) => {
      if (index % itemsPerRow === 0 && index !== 0) {
        if (buffer.length > 0) {
          buffer.forEach((previewOutletElement) => {
            this.element.insertBefore(previewOutletElement, tile.element)
          })

          buffer = []
        }
      }

      buffer.push(tile.previewOutletElement)
    })

    if (buffer.length > 0) {
      buffer.forEach((previewOutletElement) => {
        this.element.appendChild(previewOutletElement)
      })
    }

    this.adjustPreviewMargins()
  }
}
