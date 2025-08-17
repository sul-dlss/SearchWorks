import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmark-all"
export default class extends Controller {
  static values = {
    finishedLabel: String
  }
  static outlets = ['bookmark']

  connect() {
    this.update()
  }

  async selectAll() {
    const bookmarks = this.bookmarkOutlets.filter(bookmark => !bookmark.isBookmarked())
    const bookmarksData = bookmarks.map(bookmark => ({
      document_id: bookmark.element.dataset.documentId,
      document_type: 'SolrDocument'
    }))

    if (bookmarksData.length === 0) return

    this.element.disabled = true

    try {
      const response = await fetch('/selections', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ bookmarks: bookmarksData })
      })

      if (response.ok) {
        bookmarks.forEach(bookmark => {
          this.updateBookmarkVisualState(bookmark)
        })
        this.showCompletionToast()
      } else {
        console.error('Failed to save all records:', response.status)
      }
    } catch (error) {
      console.error(error)
    }
  }

  updateBookmarkVisualState(bookmark) {
    const bookmarkInput = bookmark.bookmarkInput(bookmark.element)
    bookmarkInput.checked = true
    bookmark.updateAriaTooltip(bookmark.element, true)
    bookmark.updateOtherPageBookmarks(bookmark.element.dataset.documentId, true)
  }

  update(event) {
    this.element.disabled = this.allBookmarked()
  }

  allBookmarked() {
    const bookmarks = this.bookmarkOutlets

    for (const bookmark of bookmarks) {
      if (!bookmark.isBookmarked()) {
        return false
      }
    }
    
    return true
  }

  showCompletionToast() {
    const message = `<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> ${this.finishedLabelValue}`
    window.dispatchEvent(new CustomEvent('show-toast', { detail: { html: message } }))
  }
}
