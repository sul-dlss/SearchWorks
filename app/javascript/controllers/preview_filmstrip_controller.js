import { Controller } from "@hotwired/stimulus"

// Filmstrip view for an image collection e.g. https://searchworks.stanford.edu/view/13156376
export default class extends Controller {
  static values = {
    url: String,
    id: String,
    selector: String
  }

  connect() {
    this.triggerBtn = document.createElement('button')
    this.triggerBtn.classList.add('btn', 'preview-trigger-btn', 'preview-opacity')
    this.triggerBtn.dataset.action = 'click->preview-filmstrip#togglePreview'
    this.triggerBtn.innerHTML = '<span class="bi-chevron-down small"></span>'
    this.arrow = document.createElement('div');
    this.arrow.className = 'preview-arrow';

    // NOTE: The filmstrip, viewport, prevew ,and closeBtn are outside of the controller.
    this.filmstrip = this.element.closest('.image-filmstrip');
    this.viewport = this.filmstrip.querySelector('.viewport');
    this.preview = document.querySelector(this.selectorValue);
    this.closeBtn = document.createElement('button');
    this.closeBtn.type = 'button';
    this.closeBtn.className = 'preview-close btn-close';
    this.closeBtn.setAttribute('aria-label', 'Close');
    this.closeBtn.innerHTML = '<span aria-hidden="true" class="visually-hidden">×</span>';

    this.appendTriggers()
  }

  appendTriggers() {
    this.element.append
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
    button.innerHTML = '<span class="bi-chevron-down small"></span>'
  }

  showPreview() {
    const prevOpenButton = document.querySelector('.preview-open')
    if (prevOpenButton) this.toggleButtonClosed(prevOpenButton)
    this.triggerBtn.classList.add('preview-open')
    this.triggerBtn.innerHTML = '<span class="bi-chevron-up small"></span>'
    const divContent = document.createElement('div');
    divContent.className = 'preview-content';

    this.preview.innerHTML = '';

    this.appendPointer()
    divContent.innerHTML = `<turbo-frame src="${this.urlValue}" id="preview_${this.idValue}"></turbo-frame>`

    this.preview.appendChild(divContent);
    this.preview.appendChild(this.closeBtn);
    this.preview.style.display = 'block';

    this.viewport.style.overflowX = 'hidden';
    this.attachPreviewEvents()
  }

  appendPointer() {
    this.preview.appendChild(this.arrow);

    const maxLeft = this.preview.offsetWidth - this.arrow.offsetWidth - 1
    let arrowLeft = parseInt(this.element.offsetLeft + (this.element.offsetWidth/2) - 20);

    if (arrowLeft < 0) arrowLeft = 0;
    if (arrowLeft > maxLeft) arrowLeft = maxLeft;

    this.arrow.style.left = arrowLeft + 'px';
  }

  // TODO: the preview is outside of this controller's scope.
  attachPreviewEvents() {
    this.closeBtn.addEventListener('click', () => this.closePreview());
  }

  closePreview() {
    this.toggleButtonClosed(this.triggerBtn);
    this.viewport.style.overflowX = 'scroll';
    this.preview.innerHTML = '';
    this.preview.style.display = 'none';
  }
}
