import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="facet-list"
export default class extends Controller {
  static targets = ['showButton', 'hideButton', 'hideFacets']

  connect() {
    this.element.querySelectorAll('.facet-limit').forEach(facet => facet.classList.add('d-xxl-block'))
    this.hide();
  }

  hideFacets() {
    return this.hideFacetsTarget.querySelectorAll('.facet-limit')
  }

  show() {
    this.hideFacets().forEach(facet => facet.classList.remove('d-none'))
    this.showButtonTarget.hidden = true
    this.hideButtonTarget.hidden = false
  }

  hide() {
    this.hideFacets().forEach(facet => facet.classList.add('d-none'))
    this.hideButtonTarget.hidden = true
    this.showButtonTarget.hidden = false
  }
}
