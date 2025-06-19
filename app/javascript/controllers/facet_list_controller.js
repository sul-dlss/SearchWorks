import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="facet-list"
export default class extends Controller {
  static targets = ['button', 'hideFacets']

  connect() {
    this.element.querySelectorAll('.facet-limit').forEach(facet => facet.classList.add('d-xxl-block'))
    this.#hide();
  }

  hideFacets() {
    return this.hideFacetsTarget.querySelectorAll('.facet-limit')
  }

  toggle() {
    this.buttonTarget.getAttribute('aria-expanded') === 'true' ? this.#hide() : this.#show()
  }

  #show() {
    this.hideFacets().forEach(facet => facet.classList.remove('d-none'))
    this.buttonTarget.setAttribute('aria-expanded', 'true')
    this.buttonTarget.innerHTML = '<i class="bi bi-sliders" aria-hidden="true"></i> Hide filters'
  }

  #hide() {
    this.hideFacets().forEach(facet => facet.classList.add('d-none'))
    this.buttonTarget.setAttribute('aria-expanded', 'false')
    this.buttonTarget.innerHTML = '<i class="bi bi-sliders" aria-hidden="true"></i> Show all filters'
  }
}
