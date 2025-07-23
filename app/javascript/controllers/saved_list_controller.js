import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="saved-list"
export default class extends Controller {
  static targets = ['count']

  bookmarksUpdated(event) {
    if (event.detail.checked == true) return
    const record = document.querySelector(`[data-document-id="${event.detail.document_id}"]`)
    record.style.transition = 'opacity 0.5s ease';
    record.style.opacity = 0;

    record.addEventListener('transitionend', () => {
      Turbo.visit(document.baseURI, { action: 'replace' })
    }, { once: true });    
  }
}
