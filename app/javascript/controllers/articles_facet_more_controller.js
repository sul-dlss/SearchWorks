import Blacklight from "blacklight-frontend"
import { Controller } from "@hotwired/stimulus"

// Opens long facet lists in a modal
export default class extends Controller {
  static values = { title: String }
  static targets = ["list"]

  open(e) {
    e.preventDefault()
    Blacklight.Modal.show()
    const modalContent = document.querySelector(".modal-content")

    modalContent.innerHTML = this.modalHtml(this.titleValue)

    const modalBody = document.querySelector(".dialog-body")
    modalContent.dataset.controller = "articles-facet-paginate"
    const list = this.listTarget.cloneNode(true)
    list.dataset.articlesFacetPaginateTarget = "list"
    modalBody.replaceChildren(list)
    list.querySelectorAll("[hidden]").forEach(item => item.hidden = false)
  }

  modalHtml(title) {
    return `
      <div class="dialog-header">
        <h2 class="dialog-title">${title}</h2>
        <button type="button" class="blacklight-modal-close btn-close" data-bl-dismiss="modal" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true" class="visually-hidden">×</span>
        </button>
      </div>
      <div class="dialog-header mx-5 px-0 py-3">
        <div class="facet-pagination d-flex flex-row justify-content-between w-100">
          <div class="prev_next_links btn-group">
            <button class="btn btn-link" disabled data-articles-facet-paginate-target="prev" data-action="articles-facet-paginate#previous">« <span class="d-none sm:d-inline">Previous</span></a>
            <button class="btn btn-link" data-articles-facet-paginate-target="next" data-action="articles-facet-paginate#next"><span class="d-none sm:d-inline">Next</span> »</a>
          </div>

          <div class="sort-options">
            <button class="btn btn-sm btn-outline theme-primary dropdown-toggle" type="button" data-bs-toggle="menu" data-bs-placement="bottom-end" aria-expanded="false" data-articles-facet-paginate-target="sortLabel">
              Sort by number of matches
            </button>
            <div class="menu">
              <button class="menu-item" type="button" data-action="articles-facet-paginate#sortAlpha">A-Z</button>
              <button class="menu-item" type="button" data-action="articles-facet-paginate#sortNum">Number of matches</button>
            </div>
          </div>
        </div>
      </div>
      <div class="dialog-body"></div>
      <div class="dialog-footer">
        <div class="facet-pagination bottom d-flex flex-row w-100">
          <div class="prev_next_links btn-group">
            <button class="btn btn-link" disabled data-articles-facet-paginate-target="prev" data-action="articles-facet-paginate#previous">« <span class="d-none sm:d-inline">Previous</span></a>
            <button class="btn btn-link" data-articles-facet-paginate-target="next" data-action="articles-facet-paginate#next"><span class="d-none sm:d-inline">Next</span> »</a>
          </div>
        </div>
      </div>`
  }
}
