import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmark-all"
export default class extends Controller {
  static outlets = ['bookmark']
  static targets = ['checkbox']

  connect() {
    this.update()
    if (this.bookmarkOutlets.length > 0) {
      this.element.removeAttribute('disabled')
    }
  }

  async toggleAll() {
    this.checkboxTarget.checked ? await this.removeAll() : await this.selectAll()
  }

  async removeAll() {
    const bookmarks = this.bookmarkOutlets.filter(bookmark => bookmark.isBookmarked())
    await this.performBulkBookmarkAction(bookmarks, '/selections', 'DELETE')
  }

  async selectAll() {
    const bookmarks = this.bookmarkOutlets.filter(bookmark => !bookmark.isBookmarked())
    await this.performBulkBookmarkAction(bookmarks, '/selections', 'POST')
  }

  async performBulkBookmarkAction(bookmarks, url, method) {
    const bookmarksData = bookmarks.map(bookmark => ({
      document_id: bookmark.element.dataset.documentId,
      document_type: this.documentTypeFor(bookmark),
      record_type: this.recordTypeFor(bookmark)
    }))

    if (bookmarksData.length === 0) return

    this.element.setAttribute('disabled', true)

    try {
      const response = await fetch(url, {
        method: method,
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': document.querySelector('meta[name=csrf-token]')?.content
        },
        body: JSON.stringify({ bookmarks: bookmarksData })
      })

      if (response.ok) {
        this.checkboxTarget.checked = !this.checkboxTarget.checked
        const newState = this.checkboxTarget.checked
        const result = await response.json()
        bookmarks.forEach(bookmark => bookmark.updateBookmarksFor(bookmark.element.dataset.documentId, newState));
        this.updateBookmarksCounters(result.bookmarks.count)
        this.updateAria()
      } else {
        console.error(`Failed to perform bulk selection action:`, response.status || response)
      }
    } catch (error) {
      console.error(error)
    } finally {
      this.element.removeAttribute('disabled')
    }
  }

  update(event) {
    this.checkboxTarget.checked = this.allBookmarked()
    this.updateAria()
  }

  updateAria() {
    this.element.ariaLabel = this.checkboxTarget.checked ? 'Remove all saved records on this page' : 'Save all records on this page'
    this.element.dispatchEvent(new CustomEvent('update-tooltip', { bubbles: true }))
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

  documentTypeFor(bookmark) {
    return bookmark.element.querySelector('input[name="bookmarks[][document_type]"]')?.value || 'SolrDocument'
  }

  recordTypeFor(bookmark) {
    return bookmark.element.querySelector('input[name="bookmarks[][record_type]"]')?.value || 'catalog'
  }

  bookmarksCounter() {
    return document.querySelectorAll('[data-role="bookmark-counter"]')
  }

  updateBookmarksCounters(count) {
    this.bookmarksCounter().forEach(counter => {
      counter.innerHTML = count;
    });
  }
}
