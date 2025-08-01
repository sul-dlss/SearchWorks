import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  // https://github.com/projectblacklight/blacklight/pull/3694/files
  fixupBackdrop() {
    document.body.style.removeProperty('overflow');
    document.body.style.removeProperty('padding-right');
  }
}
