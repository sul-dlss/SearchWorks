import { Controller } from "@hotwired/stimulus"
import PreviewContent from '../preview-content'

// Shows previews on the brief results view
export default class extends Controller {
  static values = {
    url: String
  }

  static targets = ["preview", "showButton", "hideButton"]

  showPreview() {
    this.previewTarget.classList.add('preview')
    PreviewContent.append(this.urlValue, $(this.previewTarget));
    this.showButtonTarget.hidden = true
    this.hideButtonTarget.hidden = false
  }

  closePreview() {
    this.previewTarget.classList.remove('preview')
    this.showButtonTarget.hidden = false
    this.hideButtonTarget.hidden = true
  }
}
