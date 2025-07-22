import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="facet-list"
export default class extends Controller {
  static targets = ['button', 'title', 'hideFacets']

  connect() {
  }

  // https://github.com/projectblacklight/blacklight/pull/3694/files
  fixupBackdrop() {
    document.body.style.removeProperty('overflow');
    document.body.style.removeProperty('padding-right');
  }
}
