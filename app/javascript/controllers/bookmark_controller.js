import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmark"
export default class extends Controller {
  static targets = ['icon', 'checkedIcon', 'hoverIcon']

  hover() {
    if (this.checked()) {
      this.checkedIconTarget.classList.add('d-none');
      this.hoverIconTarget.classList.remove('d-none');
    }
  }

  checked() {
    return this.element.querySelector('input[type="checkbox"]').checked
  }

  blur() {
    this.checkedIconTarget.classList.remove('d-none');
    this.hoverIconTarget.classList.add('d-none')
  }

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
    const toast = document.getElementById('toast-template').content.cloneNode(true).querySelector('.toast');
    const toastText = toast.querySelector('.toast-text')
    this.updateAriaTooltip(this.element, event.detail.checked)

    if (event.detail.checked){
      toastText.innerHTML = '<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> Record saved'
      if (this.element.matches(':hover')) this.hover()
    } else {
      toastText.innerHTML =  '<i class="bi bi-trash-fill pe-1" aria-hidden="true"></i> Record removed'
    }

    this.updateOtherPageBookmarks(event.target.dataset.documentId, event.detail.checked)
    document.getElementById('toast-area').appendChild(toast)
  }
}
