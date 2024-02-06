import { Controller } from "@hotwired/stimulus"
import PreviewContent from '../preview-content'

export default class extends Controller {
  static values = {
    url: String
  }

  static targets = ["preview", "showButton", "hideButton"]

  showPreview() {
    this.previewTarget.classList.add('preview')
    this.appendPointer()
    PreviewContent.append(this.urlValue, $(this.previewTarget));
    this.showButtonTarget.hidden = true
    this.hideButtonTarget.hidden = false
  }

  appendPointer() {
    this.previewTarget.innerHTML = '<div class="preview-arrow"></div>'
  }

  closePreview() {
    this.previewTarget.classList.remove('preview')
    this.showButtonTarget.hidden = false
    this.hideButtonTarget.hidden = true
  }
}
