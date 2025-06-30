import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="facet-checkboxes"
export default class extends Controller {
  static targets = ['loadingIndicator']

  revealLoadingIndicator() {
    if (!this.hasLoadingIndicatorTarget) return;

    this.loadingIndicatorTarget.classList.remove('d-none')
  }

  disableItems() {
    this.element.querySelectorAll('input[type="checkbox"]', 'a').forEach((item) => {
      item.disabled = true;
      item.classList.add('disabled');
    });
  }

  toggleCheckbox(e) {
    e.target.parentElement.querySelector('a').click();
  }
  
  toggleLink(e) {
    this.revealLoadingIndicator();
    this.disableItems();
    e.target.parentElement.querySelector('input[type="checkbox"]').checked = e.target.dataset.newstate;
  }
}
