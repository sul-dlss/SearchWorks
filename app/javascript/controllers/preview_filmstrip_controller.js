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
    this.arrow = $('<div class="preview-arrow"></div>');

    // NOTE: The filmstrip, viewport, prevew ,and closeBtn are outside of the controller.
    this.filmstrip = $(this.element).closest('.image-filmstrip');
    this.viewport = this.filmstrip.find('.viewport');
    this.preview = $(this.selectorValue)
    this.closeBtn = $(`<button type="button" class="preview-close btn-close" aria-label="Close">
    <span aria-hidden="true" class="visually-hidden">×</span>
    </button>`);

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
    const divContent = $('<div class="preview-content"></div>')

    this.preview.empty();

    this.appendPointer()
    divContent[0].innerHTML = `<turbo-frame src="${this.urlValue}" id="preview_${this.idValue}"></turbo-frame>`

    this.preview
      .append(divContent)
      .append(this.closeBtn)
      .show();

    this.viewport.css('overflow-x', 'hidden');
    this.attachPreviewEvents()
  }

  appendPointer() {
    this.preview.append(this.arrow);

    const maxLeft = this.preview.width() - this.arrow.width() - 1
    let arrowLeft = parseInt($(this.element).position().left + ($(this.element).width()/2) - 20);

    if (arrowLeft < 0) arrowLeft = 0;
    if (arrowLeft > maxLeft) arrowLeft = maxLeft;

    this.arrow.css('left', arrowLeft);
  }

  // TODO: the preview is outside of this controller's scope.
  attachPreviewEvents() {
    this.closeBtn.on('click', () => this.closePreview());
  }

  closePreview() {
    this.toggleButtonClosed(this.triggerBtn);
    this.viewport.css('overflow-x', 'scroll');
    this.preview.empty().hide();
  }
}
