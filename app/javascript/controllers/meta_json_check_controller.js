import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    field: String,
    linkUrl: String,
    linkLabel: String
  }

  connect() {
    fetch(this.urlValue)
      .then((response) => response.json())
      .then((data) => this.updateElement(data))
      .catch(error => console.error('meta_json fetch failed',error))
  }

  updateElement(data) {
    if (data[this.fieldValue]){
      this.element.classList.add('mb-2')
      this.element.innerHTML = `<a href="${this.linkUrlValue}">${this.linkLabelValue}</a>`
    }
  }
}