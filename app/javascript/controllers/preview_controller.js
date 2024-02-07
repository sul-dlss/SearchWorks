import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  closePreview() {
    this.viewport.css('overflow-x', 'scroll');
    this.preview.empty().hide();
  }
}
