import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    fetch(this.urlValue)
      .then((response) => response.json())
      .then((data) => this.handleResponse(data))
      .catch(console.error)
  }

  handleResponse(data) {
    const opens = new Date(Date.parse(data[0].opens_at))
    const closes = new Date(Date.parse(data[0].closes_at))
    const now = Date.now()
    if (now > opens && now < closes)
      this.displayOpen(closes)
    else
      this.displayClosed(opens)
  }

  displayClosed(date) {
    this.element.innerHTML = `${this.circle('closed')} Closed until ${this.formatHours(date)}`
  }

  displayOpen(date) {
    this.element.innerHTML = `${this.circle('open')} Open until ${this.formatHours(date)}`
  }

  circle(status) {
    return `<span class="bi bi-circle-fill open-indicator ${status}"></span>`
  }

  formatHours(date) {
    return date.toLocaleTimeString("en-US", { hour: 'numeric'})
  }
}
