import { Controller } from "@hotwired/stimulus"

// Paginates long facet lists in a modal
export default class extends Controller {
  static targets = [ "list" , "next", "prev"]

  perPage = 20
  currentPage = 1

  connect() {
    this.items = Array.from(this.listTarget.children)
    this.total = this.items.length
    this.maxPage = Math.ceil(this.total / this.perPage)

    this.paginate()
  }

  previous() {
    this.currentPage = Math.max(1, this.currentPage - 1)
    this.paginate()
  }

  next() {
    this.currentPage = Math.min(this.maxPage, this.currentPage + 1)
    this.paginate()
  }

  paginate() {
    const firstRecord = (this.currentPage - 1) * this.perPage
    const lastRecord = this.currentPage * this.perPage

    this.items.forEach((elem, recordNum) => {
      elem.hidden = !(recordNum >= firstRecord && recordNum < lastRecord)
    })

    this.prevTarget.disabled = this.currentPage <= 1
    this.nextTarget.disabled = this.currentPage >= this.maxPage

  }

  sortAlpha() {
    console.log("alpha")
    this.items.sort((a, b) => {
      const textA = a.textContent.toUpperCase()
      const textB = b.textContent.toUpperCase()
      return textA < textB ? -1 : textA > textB ? 1 : 0
    })

    this.listTarget.innerHTML = ''
    this.items.forEach(item => this.listTarget.appendChild(item))
    this.paginate()
  }

  sortNum() {
    console.log('num')

    this.items.sort((b, a) => {
      const countA = this.intValue(a.querySelector('.facet-count').textContent)
      const countB = this.intValue(b.querySelector('.facet-count').textContent)
      return countA - countB
    })

    this.listTarget.innerHTML = '';
    this.items.forEach(item => this.listTarget.appendChild(item))
    this.paginate()
  }

  intValue(str) {
    return Number.parseInt(str.replace(/,/g, ''))
  }
}
