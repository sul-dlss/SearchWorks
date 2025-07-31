import { Controller } from "@hotwired/stimulus"

// Controls a single tile in the browse nearby ribbon
export default class extends Controller {
  static values = {
    id: String,
    url: String
  }
  static targets = [ "button" ]
  static outlets = [ "preview-embed-browse", "preview" ]

  showPreview() {
    this.previewOutlet.load(this.idValue, this.urlValue)
    this.buttonTarget.classList.add('preview-open', 'bi-chevron-up')

    this.dispatch('show');
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

  previewOpen(){
    return this.buttonTarget.classList.contains('preview-open')
  }

  closePreview() {
    this.buttonTarget.classList.remove('preview-open', 'bi-chevron-up')
    this.buttonTarget.classList.add('bi-chevron-down')
    this.previewOutlet.close()
  }

  handlePreviewClosed(event) {
    if (event.target != this.previewOutletElement) return;
    if (this.buttonTarget.classList.contains('bi-chevron-down')) return;

    this.buttonTarget.classList.remove('preview-open', 'bi-chevron-up')
    this.buttonTarget.classList.add('bi-chevron-down')
  }
}
