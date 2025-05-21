import { Controller } from "@hotwired/stimulus"
import PreviewContent from '../preview-content'

// Controls a single tile in the browse nearby ribbon
export default class extends Controller {
  static values = {
    url: String,
    previewSelector: String
  }

  connect() {
    this.previewTarget = document.querySelector(this.previewSelectorValue)
    this.triggerBtn = this.element.querySelector('*[data-behavior="preview-button-trigger"]')
    this.closeBtn = document.createElement('button')
    this.closeBtn.type = 'button'
    this.closeBtn.className = 'preview-close btn-close'
    this.closeBtn.setAttribute('aria-label', 'Close')
    this.closeBtn.innerHTML = '<span aria-hidden="true" class="visually-hidden">×</span>'
    this.arrow = document.createElement('div')
    this.arrow.className = 'preview-arrow'

    this.attachTriggerEvents()
  }

  showPreview() {
    this.previewTarget.classList.add('preview')
    this.previewTarget.innerHTML = ''
    PreviewContent.append(this.urlValue, $(this.previewTarget))
    this.previewTarget.appendChild(this.closeBtn)
    this.previewTarget.style.display = 'block'
    this.appendPointer(this.previewTarget)
    this.triggerBtn.textContent = 'Close'
    this.triggerBtn.classList.add('preview-open')
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

  attachTriggerEvents() {
    this.triggerBtn.addEventListener('click', (e) => {
      if (this.previewOpen()){
        this.closePreview()
      } else {
        this.showPreview()
      }
    })

    const content = document.getElementById('content')

    content.addEventListener('click', (e) => {
      if (!this.currentPreview(e) && (typeof e.target.dataset.accordionSectionTarget === 'undefined')){
          this.closePreview()
      }
    })
  }

  currentPreview(e){
    // Check if we're clicking in a preview
    if (e.target.closest('.preview-container')){
      return true
    } else {
      return e.target === this.triggerBtn
    }
  }

  previewOpen(){
    return this.triggerBtn.classList.contains('preview-open')
  }

  attachPreviewEvents() {
    this.closeBtn.addEventListener('click', () => {
      this.closePreview()
    })
  }

  closePreview() {
    this.previewTarget.classList.remove('preview')
    this.triggerBtn.classList.remove('preview-open')
    this.previewTarget.style.display = 'none'
    this.triggerBtn.textContent = 'Preview'
  }
}
