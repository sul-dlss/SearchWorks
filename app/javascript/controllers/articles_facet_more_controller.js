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
      <div class="modal-body"></div>`

    const body = document.querySelector('.modal-body')
    const list = this.listTarget.cloneNode(true)
    body.append(list)
    list.querySelectorAll('[hidden]').forEach(item => item.hidden = false)
  }
}
