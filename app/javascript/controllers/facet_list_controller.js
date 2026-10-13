import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="facet-list"
export default class extends Controller {
  static targets = ["button", "title", "hideFacets"]

  connect() {
    if (!this.hasHideFacetsTarget) return

    if (this.hideFacetsTarget.querySelector(".facet-limit-active")) {
      this.buttonTarget.classList.add("d-none")
    } else {
      this.#hide()
    }
  }

  hideFacets() {
    return this.hideFacetsTarget.querySelectorAll(".facet-limit")
  }

  toggle() {
    this.buttonTarget.getAttribute("aria-expanded") === "true" ? this.#hide() : this.#show()
  }

  #show() {
    this.hideFacets().forEach(facet => facet.classList.remove("md:d-none"))
    this.titleTarget?.classList.remove("md:d-none")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.buttonTarget.innerHTML = '<i class="bi bi-sliders" aria-hidden="true"></i> Hide other filters'
  }

  #hide() {
    this.hideFacets().forEach(facet => facet.classList.add("md:d-none", "2xl:d-block"))
    this.titleTarget?.classList.add("md:d-none", "2xl:d-block")
    this.buttonTarget.classList.add("2xl:d-none")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.buttonTarget.innerHTML = '<i class="bi bi-sliders" aria-hidden="true"></i> Show all filters'
  }
}
