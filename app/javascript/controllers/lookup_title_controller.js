import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    druid: String
  }

  connect() {
    fetch(`https://purl.stanford.edu/${this.druidValue}.json`)
      .then(response => response.json())
      .then(json => this.setJson(json))
  }

  setJson(json) {
    const title = json.label
    this.element.innerHTML = title
  }
}
