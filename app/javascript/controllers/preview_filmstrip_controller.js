import { Controller } from "@hotwired/stimulus"

// Filmstrip view for an image collection e.g. https://searchworks.stanford.edu/view/13156376
export default class extends Controller {
  static values = {
    url: String,
    id: String
  }

  static outlets = ['preview']

  connect() {
    this.triggerBtn = document.createElement('button')
    this.triggerBtn.classList.add('btn', 'preview-trigger-btn', 'preview-opacity')
    this.triggerBtn.ariaLabel = 'Show preview'
    this.triggerBtn.dataset.action = 'click->preview-filmstrip#togglePreview'
    this.triggerBtn.innerHTML = '<span class="bi-chevron-down small"></span>'

    // NOTE: The filmstrip, viewport, prevew ,and closeBtn are outside of the controller.
    this.filmstrip = this.element.closest('.image-filmstrip');
    this.viewport = this.filmstrip.querySelector('.viewport');
    this.appendTriggers()
  }

  appendTriggers() {
    this.element.append(this.triggerBtn);
  }

  togglePreview() {
    if (this.triggerBtn.classList.contains('preview-open')) {
      this.closePreview()
    } else {
      this.showPreview()
    }
  }

  toggleButtonClosed(button) {
    button.classList.remove('preview-open')
    this.triggerBtn.ariaLabel = 'Hide preview'
    button.innerHTML = '<span class="bi-chevron-down small"></span>'
  }

  showPreview() {
    const prevOpenButton = document.querySelector('.preview-open')
    if (prevOpenButton) this.toggleButtonClosed(prevOpenButton)
    this.triggerBtn.classList.add('preview-open')
    this.triggerBtn.ariaLabel = 'Hide preview'
    this.triggerBtn.innerHTML = '<span class="bi-chevron-up small"></span>'

    this.viewport.style.overflowX = 'hidden';

    this.previewOutlet.load(this.idValue, this.urlValue)
  }

  closePreview() {
    this.toggleButtonClosed(this.triggerBtn);
    this.viewport.style.overflowX = 'scroll';
    this.previewOutlet.close()
  }

  handlePreviewClose(event) {
    if (event.target != this.previewOutletElement) return;

    this.toggleButtonClosed(this.triggerBtn);
    this.viewport.style.overflowX = 'scroll';
  }
}
