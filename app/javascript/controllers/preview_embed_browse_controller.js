import { Controller } from "@hotwired/stimulus"

// Controls a single tile in the browse nearby ribbon
export default class extends Controller {
  static values = {
    id: String,
    url: String
  }

  static targets = [ "button" ]

  static outlets = [ "preview" ]


  updateButton(state) {
    if (state == 'open') {
      this.buttonTarget.classList.add('preview-open')
      this.buttonTarget.querySelector('.bi').classList.add('bi-chevron-up')
      this.buttonTarget.querySelector('.bi').classList.remove('bi-chevron-down')
      this.buttonTarget.ariaLabel = 'Hide preview'
      this
    } else if (this.buttonTarget.classList.contains('preview-open')) {
      this.buttonTarget.classList.remove('preview-open')
      this.buttonTarget.querySelector('.bi').classList.remove('bi-chevron-up')
      this.buttonTarget.querySelector('.bi').classList.add('bi-chevron-down')
      this.buttonTarget.ariaLabel = 'Show preview'
    }
  }

  showPreview() {
    this.previewOutlet.load(this.idValue, this.urlValue)

    this.updateButton('open')
    this.dispatch('show');
  }

  closePreview() {
    this.previewOutlet.close()
  }

  togglePreview() {
    if (this.previewOpen()) {
      this.closePreview()
    } else {
      this.showPreview()
    }
  }

  previewOpen(){
    return this.buttonTarget.classList.contains('preview-open')
  }

  handlePreviewClosed(event) {
    if (event.target != this.previewOutletElement) return;
    if (!this.previewOpen()) return;

    this.updateButton('closed')
  }
}
