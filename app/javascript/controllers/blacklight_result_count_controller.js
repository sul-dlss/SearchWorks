import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  static targets = ["count", "link"]

  // We don't use connect() here, because this node gets moved in the DOM, which results in 2 calls to connect()
  initialize() {
    fetch(this.urlValue, { headers: { 'accept': 'application/json' } })
      .then((response) => response.json())
      .then((data) => this.handleResponse(data))
      .catch(console.error)
  }

  handleResponse(data) {
   const count = data.total

   this.linkTarget.href = data.app_link
   this.countTarget.innerHTML = count.toLocaleString()
  }
}
