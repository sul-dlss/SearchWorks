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

  updateOtherPageBookmarks(documentId, checked) {
    const pageBookmarks = document.querySelectorAll(`.bookmark-toggle[data-document-id="${documentId}"]`)
    if (pageBookmarks.length < 2) return
    pageBookmarks.forEach((bookmark) => {
      this.updateAriaTooltip(bookmark, checked)
      bookmark.querySelector('input[name="_method"]').value = checked ? 'delete' : 'put'
      bookmark.querySelector('input[type="checkbox"]').checked = checked
      bookmark.querySelector('.bookmark-text').innerHTML = checked ? bookmark.dataset.present : bookmark.dataset.absent
    })
  }

  bookmarkUpdated(event) {
    let toastHtml;
    this.updateAriaTooltip(this.element, event.detail.checked)

    if (event.detail.checked){
      toastHtml = '<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> Record saved'
    } else {
      toastHtml =  '<i class="bi bi-trash-fill pe-1" aria-hidden="true"></i> Record removed'
    }

    if (this.isToastEnabled()) {
      window.dispatchEvent(new CustomEvent('show-toast', { detail: { html: toastHtml } }));
    }

    this.updateOtherPageBookmarks(event.target.dataset.documentId, event.detail.checked)
    this.enableToast(this.element)
  }

  bookmarkWithoutToast() {
    const bookmarkInput = this.bookmarkInput(this.element)
    if (!this.isBookmarked()) {
      this.suppressNextToast()
      bookmarkInput.click()
    }
  }

  isBookmarked() {
    const bookmarkInput = this.bookmarkInput(this.element)
    return bookmarkInput.checked == true
  }

  isToastEnabled() {
    return this.element.dataset.bookmarkSuppressToast === undefined
  }

  suppressNextToast() {
    this.element.dataset.bookmarkSuppressToast = true
  }

  enableToast() {
    this.element.removeAttribute('data-bookmark-suppress-toast')
  }

  bookmarkInput(bookmarkElement) {
    return bookmarkElement.querySelector('input[type="checkbox"]')
  }
}
