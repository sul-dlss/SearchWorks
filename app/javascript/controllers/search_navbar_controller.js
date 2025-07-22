import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-navbar"
export default class extends Controller {
  static targets = ["container"]
  static values = { additionalArticlesParams: Object }

  connect() {
  }

  toggleMode(event) {
    const path = event.target.dataset.url;
    const query = new URLSearchParams(new FormData(this.element.querySelector('.search-query-form')));

    if (this.additionalArticlesParamsValue) {
      Object.entries(this.additionalArticlesParamsValue).forEach(([key, value]) => {
        if (value) {
          query.delete(key);
          query.append(key, value);
        }
      });
    }

    const url = `${path}?${query.toString()}`;
    this.containerTarget.src = url;
  }
}
