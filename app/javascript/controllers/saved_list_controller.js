import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="saved-list"
export default class extends Controller {
  bookmarksUpdated(event) {
    if (event.detail.checked == true) return
    const record = event.target.closest("article")
    record.style.transition = "opacity 0.5s ease"
    record.style.opacity = 0

    record.addEventListener("transitionend", () => {
      Turbo.visit(document.baseURI, { action: "replace" })
    }, { once: true })
  }
}
