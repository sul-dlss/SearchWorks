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
  }

  showPreview() {
    this.previewTarget.classList.add('preview')
    this.previewTarget.innerHTML = `<turbo-frame src="${this.urlValue}" id="preview_${this.idValue}"></turbo-frame>`
    this.previewTarget.appendChild(this.closeBtn)
    this.previewTarget.style.display = 'block'
    this.appendPointer()
    this.buttonTarget.classList.add('preview-open', 'bi-chevron-up')
    this.attachPreviewEvents()
    this.hideDocumentActions()
  }

  appendPointer() {
    const target = this.previewTarget;

    const arrowContainer = document.createElement('div')
    arrowContainer.className = 'preview-arrow-container position-absolute top-0'

    const arrow = document.createElement('div')
    arrow.className = 'preview-arrow'

    arrowContainer.appendChild(arrow)

    const min = -1 * arrow.offsetWidth;
    const max = target.offsetWidth - (this.element.offsetWidth / 2);

    const positionArrow = () => {
      let arrowLeft = parseInt(this.element.getBoundingClientRect().left + (this.element.offsetWidth / 2) - target.offsetLeft)

      if (arrowLeft < min - 15 || arrowLeft > max + (this.element.offsetWidth / 2)) {
        arrow.style.display = 'none';
      } else {
        arrow.style.display = 'block';
      }

      if (arrowLeft < min) { arrowLeft = min; }
      if (arrowLeft > max) { arrowLeft = max; }

      arrow.style.left = arrowLeft + 'px'
    }

    this.element.closest('.overflow-x-scroll').addEventListener('scroll', positionArrow);

    positionArrow()

    target.appendChild(arrowContainer)
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
    this.previewTarget.classList.remove('preview')
    this.buttonTarget.classList.remove('preview-open', 'bi-chevron-up')
    this.buttonTarget.classList.add('bi-chevron-down')
    this.previewTarget.style.display = 'none'
  }
}
