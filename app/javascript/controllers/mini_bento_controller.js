import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mini-bento"
export default class extends Controller {
  static values = { count: Number, url: String }
  static targets = ["title", "count", "body", "placeholder"]
  static outlets = ["mini-mini-bento"]

  connect() {
    // mini-bento gets moved around the DOM (and it gets reconnected when that happens),
    // but we don't need to re-request bento data every time that happens.
    if (!this.element.busy && !this.element.complete) this.requestData()
  }

  requestData() {
    this.placeholderTarget.classList.remove('d-none')
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

    const count = parseInt(response.response.pages.total_count)
    this.countValue = count;

    // Update title
    this.titleTarget.innerHTML = 'Looking for more?'
    this.countTarget.innerHTML = count.toLocaleString()
    this.bodyTarget.classList.remove('d-none')
    this.placeholderTarget.classList.add('d-none')

    // inform the mini-mini-bento outlet that we have data
    this.miniMiniBentoOutlet.receiveCount(count)
  }

  // if a new mini-mini-bento outlet is connected and we already have data,
  // send it the count value
  miniMiniBentoOutletConnected(outlet, _element) {
    if (!this.countValue) return;

    outlet.receiveCount(this.countValue);
  }
}
