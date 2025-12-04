import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="purl-embed"
export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    this.loadEmbed()
  }

  loadEmbed() {
    if (this.element.attributes.complete || this.element.attributes.busy) return

    this.element.setAttribute("busy", "")

    fetch(this.urlValue)
      .then(response => response.json())
      .then(data => {
        this.element.removeAttribute("busy")
        if (data !== null) {
          this.element.innerHTML = data.html
          this.element.setAttribute("complete", "")
        }
      })
      .catch(error => console.error("Error loading embed:", error))
  }
}
