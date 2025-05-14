const AlternateCatalog = (function (global) {
  return {
    container: null,
    titleElement: null,

    init: function (el) {
      this.element = el
      this.titleElement = this.element.querySelector('.alternate-catalog-title')

      // Setup close click handler
      this.initCloseButton()

      // Insert between the 3rd and 4th document
      this.injectAlternateCatalogIntoResults()

      // Update title
      this.titleElement.innerHTML = 'Searching...'

      // Try other catalog
      this.fetchOtherCatalog()
    },

    initCloseButton: function () {
      const close = this.element.querySelector('.btn-close');
      if (!close)
        return // There is no close on the no-results page

      close.addEventListener('click', () => this.element.remove())
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
      const facets = this.element.querySelector('.alternate-catalog-facets')

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
          this.titleElement.innerHTML = 'Your search also found results in'
          countElement.innerHTML = parseInt(count).toLocaleString()
          body.classList.remove('d-none')

          if (count > 0) {
            // Update body
            const facetHtml = createFacets(response.response.facets, alternateCatalogUrl)
            facets.innerHTML = facetHtml
          }
        })
    }
  }

  function createFacets(facets, url) {
    const facetLinks = []
    // Iterating over everything here would be too slow
    const sourceOrResouce = facets.filter( function(facet) {
      return facet.label === 'Source type' || facet.label === 'Resource type'
    })
    sourceOrResouce.forEach(function (facet) {
      // Iterating over everything here would be even slower.. sort it and take the top 3
      const topThree = facet.items.sort(function(a, b) {
        return b.hits - a.hits
      }).slice(0, 3)
      topThree.forEach(function (item) {
        linkedUrl = url + '&f[' + facet.name + '][]=' + encodeURI(item.value);
        const count = parseInt(item.hits).toLocaleString()
        linkText = `${item.label} <span class="badge rounded-pill text-bg-secondary">${count}</span>`
        facetLinks.push(`<li><a href="${linkedUrl}">${linkText}</a></li>`)
      })
    })
    return facetLinks.join("")
  }

}(this));

Blacklight.onLoad(function () {
  document.querySelectorAll('[data-alternate-catalog]').forEach((element) => AlternateCatalog.init(element))
})
