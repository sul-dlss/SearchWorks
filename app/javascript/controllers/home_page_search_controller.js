import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home-page-search-mode"
export default class extends Controller {
  toggle(e) {
    e.currentTarget.checked = true;

    const url = e.currentTarget.dataset.url;
    if (!url) return;

    Turbo.visit(url, { action: 'replace' });
  }

  submit() {
    delete this.element.querySelector('#q').dataset.turboPermanent;
  }
}
