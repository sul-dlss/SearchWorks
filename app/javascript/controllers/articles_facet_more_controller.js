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

    const modalBody = document.querySelector(".modal-body")
    modalContent.dataset.controller = "articles-facet-paginate"
    const list = this.listTarget.cloneNode(true)
    list.dataset.articlesFacetPaginateTarget = "list"
    modalBody.replaceChildren(list)
    list.querySelectorAll("[hidden]").forEach(item => item.hidden = false)
  }

  modalHtml(title) {
    return `
      <div class="modal-header">
        <h2 class="modal-title">${title}</h2>
        <button type="button" class="blacklight-modal-close btn-close" data-bl-dismiss="modal" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true" class="visually-hidden">×</span>
        </button>
      </div>
      <div class="modal-header mx-3 px-0 py-2">
        <div class="facet-pagination d-flex flex-row justify-content-between w-100">
          <div class="prev_next_links btn-group">
            <button class="btn btn-link" disabled data-articles-facet-paginate-target="prev" data-action="articles-facet-paginate#previous">« <span class="d-none d-sm-inline">Previous</span></a>
            <button class="btn btn-link" data-articles-facet-paginate-target="next" data-action="articles-facet-paginate#next"><span class="d-none d-sm-inline">Next</span> »</a>
          </div>

          <div class="dropdown sort-options">
            <button class="btn btn-sm btn-outline-primary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false" data-articles-facet-paginate-target="sortLabel">
              Sort by number of matches
            </button>
            <ul class="dropdown-menu dropdown-menu-end">
              <li>
                <button class="dropdown-item" type="button" data-action="articles-facet-paginate#sortAlpha">A-Z</button>
              </li>
              <li>
                <button class="dropdown-item" type="button" data-action="articles-facet-paginate#sortNum">Number of matches</button>
              </li>
            </ul>
          </div>
        </div>
      </div>
      <div class="modal-body"></div>
      <div class="modal-footer">
        <div class="facet-pagination bottom d-flex flex-row w-100">
          <div class="prev_next_links btn-group">
            <button class="btn btn-link" disabled data-articles-facet-paginate-target="prev" data-action="articles-facet-paginate#previous">« <span class="d-none d-sm-inline">Previous</span></a>
            <button class="btn btn-link" data-articles-facet-paginate-target="next" data-action="articles-facet-paginate#next"><span class="d-none d-sm-inline">Next</span> »</a>
          </div>
        </div>
      </div>`
  }
}
