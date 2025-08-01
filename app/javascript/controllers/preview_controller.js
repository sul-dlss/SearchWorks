import { Controller } from "@hotwired/stimulus"

// Controls the preview "popup" in e.g. the browse nearby ribbon or image collection filmstrip.
export default class extends Controller {
  static values = {
    id: String,
    url: String,
  }
  static targets = [ "arrow", "closeButton", "frame" ]

  connect() {
    this.appendFrame();
    this.appendButtons();
  }

  appendButtons() {
    if (!this.hasCloseButtonTarget) {
      const closeButton = document.createElement('button')
      closeButton.type = 'button'
      closeButton.className = 'preview-close btn-close'
      closeButton.setAttribute('aria-label', 'Close')
      closeButton.setAttribute('data-preview-target', 'closeButton')
      closeButton.setAttribute('data-action', 'preview#close')
      closeButton.innerHTML = '<span aria-hidden="true" class="visually-hidden">×</span>'
      this.element.appendChild(closeButton)
    }

    if (!this.hasArrowTarget) {
      const arrow = document.createElement('div')
      arrow.setAttribute('data-preview-target', 'arrow')
      arrow.className = 'preview-arrow'
      this.element.appendChild(arrow)
    }
  }

  appendFrame() {
    const frame = document.createElement('turbo-frame');
    frame.setAttribute('data-preview-target', 'frame');
    frame.setAttribute('data-preview-target', 'frame')
    this.element.appendChild(frame);
  }

  reset() {
    this.frameTarget.innerHTML = '';
  }

  load(id, url) {
    if (this.idValue != id) {
      this.reset();
      this.idValue = id
      this.urlValue = url
      this.frameTarget.setAttribute('id', `preview_${this.idValue}`)
      this.frameTarget.setAttribute('src', this.urlValue)
    }

    this.open()
  }

  open() {
    this.element.classList.add('preview', 'd-block')
    this.element.classList.remove('d-none')
    this.dispatch("open");
  }

  close() {
    this.element.classList.remove('preview', 'd-block')
    this.element.classList.add('d-none')
    this.dispatch("close");
  }
}
