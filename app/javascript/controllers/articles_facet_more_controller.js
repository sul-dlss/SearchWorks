import { Controller } from "@hotwired/stimulus"

// Opens long facet lists in a modal
export default class extends Controller {
  static values = { title: String }
  static targets = [ "list" ]

  open(e) {
    e.preventDefault()
    Blacklight.Modal.show()
    const modalContent = document.querySelector('.modal-content')

    modalContent.innerHTML = this.modalHtml(this.titleValue)

    const modalBody = document.querySelector('.modal-body')
    modalContent.dataset.controller = 'articles-facet-paginate'
    const list = this.listTarget.cloneNode(true)
    list.dataset.articlesFacetPaginateTarget = 'list'
    modalBody.replaceChildren(list)
    list.querySelectorAll('[hidden]').forEach(item => item.hidden = false)
  }

  modalHtml(title) {
    return `
      <div class="modal-header">
        <h1 class="modal-title">${title}</h1>
        <button type="button" class="blacklight-modal-close btn-close close" data-bl-dismiss="modal" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true" class="visually-hidden">×</span>
        </button>
      </div>
      <div class="modal-body"></div>
      <div class="modal-footer">
        <div class="facet-pagination bottom flex-row justify-content-between">
          <div class="prev_next_links btn-group pull-left">
            <button class="btn btn-link" disabled data-articles-facet-paginate-target="prev" data-action="articles-facet-paginate#previous"><i class="fa fa-arrow-left"></i> <span class="d-none d-sm-inline">Previous</span></a>
            <button class="btn btn-link" data-articles-facet-paginate-target="next" data-action="articles-facet-paginate#next"><span class="d-none d-sm-inline">Next</span> <i class="fa fa-arrow-right"></i></a>
          </div>


          <div class="btn-group pull-right">
            <input type="radio" class="btn-check" name="sort" id="alpha" data-action="change->articles-facet-paginate#sortAlpha">
            <label class="btn btn-secondary" for="alpha">A-Z Sort</label>
            <input type="radio" class="btn-check" name="sort" id="num" checked data-action="change->articles-facet-paginate#sortNum">
            <label class="btn btn-secondary" for="num">Numerical Sort</label>
          </div>
        </div>
      </div>`
  }
}
