import { Controller } from "@hotwired/stimulus"

// Controls a single tile in the browse nearby ribbon
export default class extends Controller {
  static values = {
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
    this.previewTarget.classList.add('preview')
    this.previewTarget.innerHTML = `<turbo-frame src="${this.urlValue}" id="preview_${this.idValue}"></turbo-frame>`
    this.previewTarget.appendChild(this.closeBtn)
    this.previewTarget.style.display = 'block'
    this.appendPointer(this.previewTarget)
    this.buttonTarget.textContent = 'Close'
    this.buttonTarget.classList.add('preview-open')
    this.attachPreviewEvents()
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

  attachPreviewEvents() {
    this.closeBtn.addEventListener('click', () => {
      this.closePreview()
    })
  }

  closePreview() {
    this.previewTarget.classList.remove('preview')
    this.buttonTarget.classList.remove('preview-open')
    this.previewTarget.style.display = 'none'
    this.buttonTarget.textContent = 'Preview'
  }
}
