import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mini-bento"
export default class extends Controller {
  static values = { url: String }
  static targets = ["title", "count", "body"]

  connect() {
    // mini-bento gets moved around the DOM (and it gets reconnected when that happens),
    // but we don't need to re-request bento data every time that happens.
    if (!this.element.busy && !this.element.complete) this.requestData()
  }

  requestData() {
    this.element.busy = true
    this.element.complete = false

    const alternateCatalogUrl = this.urlValue;

    fetch(alternateCatalogUrl, { headers: { 'accept': 'application/json' } })
      .then(response => {
          if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`)
          }
          return response.json()
      })
      .then(response => this.handleResponse(response))
      .catch((error) => {
        console.error(error)
      })
  }

  handleResponse(response) {
    this.element.busy = false
    this.element.complete = true

    const count = response.response.pages.total_count
    // Update title
    this.titleTarget.innerHTML = 'Looking for more?'
    this.countTarget.innerHTML = parseInt(count).toLocaleString()
    this.bodyTarget.classList.remove('d-none')
  }
}
