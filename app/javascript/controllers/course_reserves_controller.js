import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="course-reserves"
export default class extends Controller {
  connect() {
    // Prevent reinitializing on restore from turbo cache.
    if (document.querySelector('.dt-container'))
      return // Do not initialize datatable again
    this.setupDataTable()
  }

  setupDataTable() {
    new DataTable(this.element, {
      layout: {
        top: {
          features: ['search', 'info', 'pageLength']
        },
        topStart: null,
        topEnd: null,
        bottomStart: null,
        bottomEnd: {
            paging: {
                numbers: true,
                firstLast: false
            }
        }
      },
      language: {
        info: "_START_ to _END_ of _TOTAL_ reserve lists",
        lengthMenu: "_MENU_ per page",
        search: "Search by course ID, description, or instructor ",
        paginate: {
          previous: "<i class='fa fa-arrow-left'></i> Previous",
          next: "Next <i class='fa fa-arrow-right'></i>"
        }
      },
      pageLength: 25,
      on: {
        draw: () => {
          this.modifyPaginationElements()
        }
      }
    })

    this.modifyPaginationElements()
  }

  modifyPaginationElements() {
    // Move next button before previous button
    const nextPaginateBtn = document.querySelector('#course-reserves-browse_wrapper .dt-paging-button:has(.next)')
    if (!nextPaginateBtn)
      return

    nextPaginateBtn.remove()

    const previousPaginateBtn = document.querySelector('#course-reserves-browse_wrapper .dt-paging-button:has(.previous)')
    previousPaginateBtn.after(nextPaginateBtn)
  }
}
