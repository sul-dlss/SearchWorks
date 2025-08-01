import { Controller } from "@hotwired/stimulus"

// Controls a single tile in the browse nearby ribbon
export default class extends Controller {
  static values = {
    id: String,
    url: String
  }
  static targets = [ "button" ]
  static outlets = [ "preview" ]

  showPreview() {
    this.previewOutlet.load(this.idValue, this.urlValue)
    this.updateButton('open')
    this.dispatch('show');
  }

  updateButton(state) {
    if (state == 'open') {
      this.buttonTarget.classList.add('preview-open', 'bi-chevron-up')
      this.buttonTarget.classList.remove('bi-chevron-down')
    } else {
      this.buttonTarget.classList.remove('preview-open', 'bi-chevron-up')
      this.buttonTarget.classList.add('bi-chevron-down')
    }
  }

  togglePreview(e) {
    if (this.previewOpen()){
      this.previewOutlet.close()
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

    this.closePreview();
    this.updateButton('closed')
  }
}
