import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="facet-list"
export default class extends Controller {
  static targets = ['button', 'title', 'hideFacets']

  connect() {
    if (!this.hasHideFacetsTarget) return;

    if (this.hideFacetsTarget.querySelector('.facet-limit-active')) {
      this.buttonTarget.classList.add('d-none');
    } else {
      this.#hide();
    }
  }

  hideFacets() {
    return this.hideFacetsTarget.querySelectorAll('.facet-limit')
  }

  toggle() {
    this.buttonTarget.getAttribute('aria-expanded') === 'true' ? this.#hide() : this.#show()
  }

  #show() {
    this.hideFacets().forEach(facet => facet.classList.remove('d-md-none'))
    this.titleTarget?.classList.remove('d-md-none')
    this.buttonTarget.setAttribute('aria-expanded', 'true')
    this.buttonTarget.innerHTML = '<i class="bi bi-sliders" aria-hidden="true"></i> Hide other filters'
  }

  #hide() {
    this.hideFacets().forEach(facet => facet.classList.add('d-md-none', 'd-xxl-block'))
    this.titleTarget?.classList.add('d-md-none', 'd-xxl-block')
    this.buttonTarget.classList.add('d-xxl-none')
    this.buttonTarget.setAttribute('aria-expanded', 'false')
    this.buttonTarget.innerHTML = '<i class="bi bi-sliders" aria-hidden="true"></i> Show all filters'
  }
}
