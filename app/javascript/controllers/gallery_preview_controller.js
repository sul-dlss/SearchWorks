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

    this.attachPreviewEvents()
  }

  clamp(x, min, max) {
    return Math.min(Math.max(x, min), max)
  }

  appendPointer() {
    this.previewTarget.appendChild(this.arrow)

    const maxLeft = this.previewTarget.offsetWidth - this.arrow.offsetWidth - 1
    const { left, width } = this.element.getBoundingClientRect()
    const docsLeft = document.getElementById('documents').getBoundingClientRect().left
    const arrowLeft = this.clamp(left - docsLeft + width / 2 - 10, 0, maxLeft)

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
    const targetDoc = document.querySelector(`.gallery-document[data-doc-id='${docId}']`)
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
