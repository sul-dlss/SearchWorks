import { Controller } from "@hotwired/stimulus"


// Connects to data-controller="course-reserves"
export default class extends Controller {
  static targets = ['table', 'tableBody', 'sortButton', 'perPageButton', 'sortItem', 'perPageItem', 'results', 'bottomPagination']
  static classes = ['activeMenuItem']

  getCellValue = (tr, idx) => {
    const val = tr.children[idx].innerText || tr.children[idx].textContent
    return val.trim()
  }

  comparer = (columnIdx) => (a, b) => ((v1, v2) => v1.localeCompare(v2))(this.getCellValue(a, columnIdx), this.getCellValue(b, columnIdx))


  connect() {
    this.sortColumn = 0
    this.pageRows = 20
    this.total = this.rows.length
    this.currentPage = 0
    this.searchFilter = ""
    this.draw()
  }

  get rows() {
    return Array.from(this.tableBodyTarget.querySelectorAll("tr"))
  }

  get totalPages() {
    return Math.ceil(this.total / this.pageRows)
  }

  get pageMax() {
    return Math.min((this.currentPage + 1) * this.pageRows, this.total)
  }

  get hasPrevious() {
    return this.currentPage > 0
  }

  get hasNext() {
    return this.pageMax < this.total
  }

  draw() {
    this.drawTopResults()
    this.drawBottomPagination()
    this.rows.
      sort(this.comparer(this.sortColumn)).
      forEach((row) => {
        this.tableBodyTarget.appendChild(row)
      })

    let numberDrawn = 0
    let numberSkipped = 0
    let numberToSkip = this.currentPage * this.pageRows
    // Loop through all table rows, and hide those who don't match the search query and aren't on the current page.
    this.tableBodyTarget.querySelectorAll("tr").forEach((tr) => {
      if (numberDrawn < this.pageRows && this.rowMatches(tr, this.searchFilter)) {
        if (numberSkipped < numberToSkip) {
          numberSkipped++
          tr.classList.add("d-none")
        } else {
          tr.classList.remove("d-none")
          numberDrawn++
        }
      } else {
        tr.classList.add("d-none")
      }
    })
  }

  get nextIcon() {
    return `»`
  }

  get prevIcon() {
    return `«`
  }

  drawTopResults() {
    const info = `<strong>${this.currentPage * this.pageRows + 1} - ${this.pageMax}</strong> of <strong>${this.total}</strong>`
    const nextButton = this.hasNext ? `<a class="ms-2" rel="next" href="#" data-action="course-reserves#nextPage">Next ${this.nextIcon}</a>` : ``
    const prevButton = this.hasPrevious ? `<a class="me-2" rel="prev" href="#" data-action="course-reserves#prevPage">${this.prevIcon} Previous</a>` : `<button disabled class="btn btn-link btn-disabled text-start align-baseline p-0 disabled me-2">${this.prevIcon} Previous</button>`
    this.resultsTarget.innerHTML = `<nav class="page_links page-entries-info" aria-label="Pagination">${prevButton}${info}${nextButton}</nav>`
  }

  drawBottomPagination() {
    const prevItem = `<li class="page-item${this.hasPrevious ? '' : ' disabled'}"><a class="page-link" rel="prev" href="#" data-action="course-reserves#prevPage">${this.prevIcon} Previous</a></li>`
    const nextItem = `<li class="page-item${this.hasNext ? '' : ' disabled'}"><a class="page-link" rel="next" href="#" data-action="course-reserves#nextPage">Next ${this.nextIcon}</a></li>`
    this.bottomPaginationTarget.innerHTML = `<nav class="page_links page-entries-info" aria-label="Pagination links"><ul class="pagination">${prevItem}${this.pageLinks()}<li>${nextItem}</li></ul></nav>`
  }

  pageLinks() {
    const outerWindow = 2
    const innerWindow = 2

    const links = []

    const pagesToRender = [];

    for (let i = 0; i < this.totalPages; i++) {
      if (i < outerWindow || i >= this.totalPages - outerWindow || (i >= this.currentPage - innerWindow && i <= this.currentPage + innerWindow) ||
          (this.currentPage < outerWindow && i <= outerWindow + innerWindow)
        ) {
        pagesToRender.push(i)
      } else {
        if (pagesToRender[pagesToRender.length - 1] != 'gap') pagesToRender.push('gap')
      }
    }

    pagesToRender.forEach((i) => {
      if (i == 'gap') {
        links.push('<li class="page-item disabled"><span class="page-link">...</span></li>')
        return
      }

      const active = i === this.currentPage
      const link = `<li class="page-item${active ? ' active' : ''}"><a class="page-link" href="#${i}" data-action="course-reserves#gotoPage">${i + 1}</a></li>`
      links.push(link)
    })

    return links.join('')
  }

  gotoPage(e){
    e.preventDefault()
    this.currentPage = parseInt(e.target.hash.replace('#', ''))
    this.draw()
  }

  sort(e) {
    e.preventDefault()
    this.sortColumn = parseInt(URL.parse(e.target.href).hash.replace('#', ''))

    const colName = this.tableTarget.querySelector(`th:nth-child(${this.sortColumn + 1})`).textContent
    this.sortButtonTarget.innerHTML = `Sort<span class="d-none d-lg-inline"> by ${colName}</span>`

    this.sortItemTargets.forEach((item, idx) => {
      item.getAttribute('aria-current', idx === this.sortColumn)
      item.querySelector('.active-icon').classList.toggle(this.activeMenuItemClass, idx === this.sortColumn)
    })

    this.draw()
  }

  prevPage(e) {
    e.preventDefault()
    this.currentPage = Math.max(this.currentPage - 1, 0)
    this.draw()
  }

  nextPage(e) {
    e.preventDefault()
    this.currentPage = Math.min(this.currentPage + 1, this.totalPages)
    this.draw()
  }

  perPage(e) {
    e.preventDefault()
    this.pageRows = parseInt(URL.parse(e.target.href).hash.replace('#', ''))
    this.currentPage = 0
    this.perPageButtonTarget.innerHTML = `${this.pageRows} <span class="d-none d-lg-inline"> per page</span>`

    this.perPageItemTargets.forEach((item) => {
      const current = item.getAttribute('href') === `#${this.pageRows}`
      item.getAttribute('aria-current', current)
      item.querySelector('.active-icon').classList.toggle(this.activeMenuItemClass, current)
    })

    this.draw()
  }


  search(event) {
    this.searchFilter = event.target.value.toLowerCase()
    this.currentPage = 0

    if (this.searchFilter === '')
      this.total = this.rows.length
    else
      this.total = Array.from(this.tableBodyTarget.querySelectorAll("tr"))
        .filter(tr => this.rowMatches(tr, this.searchFilter)).length

    this.draw()
  }

  rowMatches(tr, filter) {
    if (filter === '') return true;

    const tds = tr.getElementsByTagName("td")

    return Array.from(tds).some((td) => {
      const txtValue = td.textContent || td.innerText
      return txtValue.toLowerCase().includes(filter)
    })
  }
}
