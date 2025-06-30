import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mini-bento"
// Other search tools in blacklight_result_count_controller
export default class extends Controller {
  static targets = ['title', 'count', 'body']
  static values = {
    alternateCatalogUrl: String
  }
  connect(){
    if (window.innerWidth > 768) {
      this.element.classList.add('show');
    }
    this.fetchOtherCatalog();
  }
  closeBento() {
    new bootstrap.Collapse(this.element);
  }
  fetchOtherCatalog() {
    fetch(this.alternateCatalogUrlValue, { headers: { 'accept': 'application/json' } })
      
    .then(response => {
          if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`)
          }
          return response.json()
      })
      .then(response => {
        const count = response.response.pages.total_count
        // Show title
        this.titleTarget.innerHTML = 'Looking for more?';
        this.countTarget.innerHTML = parseInt(count).toLocaleString();
        this.bodyTarget.classList.remove('d-none');
      })
      .catch((error) => {
        console.error(error)
      })
  }
}
