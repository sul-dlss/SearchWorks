import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmark"
export default class extends Controller {
  static targets = ['icon']

  updateAriaTooltip(bookmark, checked) {
    if (checked) { 
      bookmark.dataset.tooltip = 'Remove from saved records'
      bookmark.ariaLabel = bookmark.ariaLabel.replace('Save record', 'Remove from saved records')
    } else {
      bookmark.dataset.tooltip = 'Save record'
      bookmark.ariaLabel = bookmark.ariaLabel.replace('Remove from saved records', 'Save record')
    }
    bookmark.dispatchEvent(new CustomEvent('update-tooltip', { bubbles: true}))
  }

  updateBookmarksFor(documentId, state) {
    const bookmarksForDoc = document.querySelectorAll(`.bookmark-toggle[data-document-id="${documentId}"]`)
    bookmarksForDoc.forEach(bookmark => this.updateStateFor(bookmark, state))
  }

  updateStateFor(bookmark, state) {
    if (this.bookmarkInput(bookmark).checked == state) return

    this.bookmarkInput(bookmark).checked = state
    bookmark.querySelector('input[name="_method"]').value = state ? 'delete' : 'put'
    bookmark.querySelector('.bookmark-text').innerHTML = state ? bookmark.dataset.present : bookmark.dataset.absent
    const label = bookmark.querySelector('[data-checkboxsubmit-target="label"]')
    state ? label.classList.add('checked') : label.classList.remove('checked')
    this.updateAriaTooltip(bookmark, state)
  }

  bookmarkUpdated(event) {
    let toastHtml;
    this.updateAriaTooltip(this.element, event.detail.checked)

    if (event.detail.checked){
      toastHtml = '<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> Record saved'
    } else {
      toastHtml =  '<i class="bi bi-trash-fill pe-1" aria-hidden="true"></i> Record removed'
    }

    window.dispatchEvent(new CustomEvent('show-toast', { detail: { html: toastHtml } }));

    this.updateBookmarksFor(event.target.dataset.documentId, event.detail.checked)
  }

  isBookmarked() {
    const bookmarkInput = this.bookmarkInput(this.element)
    return bookmarkInput.checked == true
  }

  bookmarkInput(bookmarkElement) {
    return bookmarkElement.querySelector('input[type="checkbox"]')
  }
}
