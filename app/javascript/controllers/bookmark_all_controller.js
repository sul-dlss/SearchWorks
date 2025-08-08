import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmark-all"
export default class extends Controller {
  static values = {
    inProgress: Boolean,
    finishedLabel: String
  }
  static outlets = ['bookmark']

  connect() {
    this.pendingBookmarks = new Set()
    this.update()
  }

  async selectAll() {
    const batchSize = 20
    const betweenBookmarkDelay = 30
    const betweenBatchDelay = 500
    const bookmarks = this.bookmarkOutlets.filter(bookmark => !bookmark.isBookmarked())

    this.element.disabled = true
    this.inProgressValue = true
    this.setPending(bookmarks)

    for (let i = 0; i < bookmarks.length; i += batchSize) {
      const batch = bookmarks.slice(i, i + batchSize)

      // Process batch
      await Promise.all(batch.map(bookmark => {
        return new Promise(resolve => {
          setTimeout(() => {
            bookmark.bookmarkWithoutToast()
            resolve()
          }, betweenBookmarkDelay)
        })
      }))

      if (i + batchSize < bookmarks.length) {
        await new Promise(resolve => setTimeout(resolve, betweenBatchDelay))
      }
    }
  }

  update(event) {
    if (this.inProgressValue && event) {
      // Our bookmark checkboxes update state optimistically, so `isBookmarked` does as well.
      // Here we are checking for true, reported success from the bookmark.blacklight event
      const documentId = event.target.dataset.documentId

      this.pendingBookmarks.delete(documentId)

      if (this.pendingBookmarks.size === 0) {
        this.element.disabled = true
        this.resetProgress()
        this.showCompletionToast()
        return
      }
    }

    const allBookmarked = this.allBookmarked()
    if (!this.inProgressValue) {
      this.element.disabled = allBookmarked
    }
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

  setPending(bookmarks) {
    this.pendingBookmarks.clear()
    bookmarks.forEach(bookmark => {
      const documentId = bookmark.element.dataset.documentId
      this.pendingBookmarks.add(documentId)
    })
  }

  resetProgress() {
    this.inProgressValue = false
  }
}
