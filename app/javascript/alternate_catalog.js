import Blacklight from 'blacklight-frontend'

const AlternateCatalog = (function (global) {
  return {
    container: null,
    titleElement: null,

    init: function (el) {
      this.element = el
      this.titleElement = this.element.querySelector('.alternate-catalog-title')

      // Setup close click handler
      this.initCloseButton()

      // Insert between the 3rd and 4th document for articles
      if (document.querySelector('.blacklight-articles')) {
        this.injectAlternateCatalogIntoResults()
      }

      if (window.innerWidth > 768) {
        this.element.classList.add('show');
      }

      // Update title
      this.titleElement.innerHTML = 'Searching...'

      // Try other catalog
      this.fetchOtherCatalog()
    },

    initCloseButton: function () {
      const close = this.element.querySelector('.btn-close');
      if (!close)
        return // There is no close on the no-results page

      close.addEventListener("click", () => {
        new bootstrap.Collapse(this.element);
      })
    },

    injectAlternateCatalogIntoResults: function () {
      const documentList = document.querySelector('#documents')
      if (!documentList)
        return // Don't move on the no-results page

      const afterThird = documentList.querySelector('.document-position-2')

      // If there is no third document, just append to the end of #documents
      if (afterThird) {
        afterThird.after(this.element)
      } else {
        documentList.append(this.element)
      }
    },

    fetchOtherCatalog: function() {
      const alternateCatalogUrl = this.element.dataset.alternateCatalog
      const body = this.element.querySelector('.alternate-catalog-body')
      const countElement = this.element.querySelector('.alternate-catalog-count')

      fetch(alternateCatalogUrl, { headers: { 'accept': 'application/json' } })
        .then(response => {
            if (!response.ok) {
              throw new Error(`HTTP error! Status: ${response.status}`)
            }
            return response.json()
        })
        .then(response => {
          const count = response.response.pages.total_count
          // Update title
          this.titleElement.innerHTML = 'Looking for more?'
          countElement.innerHTML = parseInt(count).toLocaleString()
          body.classList.remove('d-none')
        })
        .catch((error) => {
          console.error(error)
        })
    }
  }

}(this));

Blacklight.onLoad(function () {
  document.querySelectorAll('[data-alternate-catalog]').forEach((element) => AlternateCatalog.init(element))
})
