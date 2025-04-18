import { Controller } from "@hotwired/stimulus"

// Opens long facet lists in a modal
export default class extends Controller {
  static values = { title: String }
  static targets = [ "list" ]

  open(e) {
    e.preventDefault()
    Blacklight.modal.show()
    const modalContent = document.querySelector('.modal-content')

    modalContent.innerHTML =`
      <div class="modal-header">
        <h1 class="modal-title">${this.titleValue}</h1>
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


          <div class="btn-group btn-group-toggle pull-right" data-toggle="buttons">
            <label class="btn btn-secondary">
              <input type="radio" name="sort" id="alpha" data-action="change->articles-facet-paginate#sortAlpha"> A-Z Sort
            </label>
            <label class="btn btn-secondary active">
              <input type="radio" name="sort" id="num" checked data-action="change->articles-facet-paginate#sortNum"> Numerical Sort
            </label>
          </div>
        </div>
      </div>`

    const body = document.querySelector('.modal-body')
    modalContent.dataset.controller = 'articles-facet-paginate'
    const list = this.listTarget.cloneNode(true)
    list.dataset.articlesFacetPaginateTarget = 'list'
    body.append(list)
    list.querySelectorAll('[hidden]').forEach(item => item.hidden = false)
  }
}
