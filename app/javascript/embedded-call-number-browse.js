import PreviewContent from './preview-content'
(function($) {

  /*
    jQuery plugin to add embedded browse view to a show page

      Usage: $(selector).embedBrowse();

    This plugin :
      - adds preview triggers to the gallery preview button
      - on preview click event, fetches preview content from
        'data-preview-url' data attribute value and renders it
  */

  // Scroll to the current document
  const scrollOver = function(element, gallery) {
    const parentWidth = element.parentNode.offsetWidth
    const elementWidth = element.offsetWidth

    // Get the element's position relative to its offsetParent.
    let left = 0
    let currentElement = element
    while (currentElement) {
      left += currentElement.offsetLeft
      currentElement = currentElement.offsetParent
    }

    const scrollAmount = left - parentWidth / 2 + elementWidth / 2
    element.classList.add('current-document')

    gallery.scrollTo({ left: scrollAmount })
  }

  $.fn.embedBrowse = function() {

    var DOC_WIDTH = 194;

    GalleryDocs = function(item) {
      this.item = item
      this.viewportTarget = document.querySelector(item.data('embed-viewport'))
      this.galleryTarget = this.viewportTarget.querySelector('.gallery')
      this.embedContainer = $(this.galleryTarget)
      this.url = item.data('url')
      this.browseUrl = item.data('index-path')
      this.currentDoc = item.data('start')
    };

    GalleryDocs.prototype.docs = function() {
      return this.viewportTarget.querySelectorAll('.gallery-document')
    };

    GalleryDocs.prototype.hasContent = function() {
      return this.docs().length !== 0
    }

    GalleryDocs.prototype.currentDocumentTarget = function() {
      return this.viewportTarget
        .querySelector(`.gallery-document[data-doc-id="${this.currentDoc}"]`)
    };

    return this.each(function() {
      var $item = $(this)
      const $galleryDoc = new GalleryDocs($item)
      init();

      function displayLink() {
        const linkViewFullPage = document.querySelector('.view-full-page a')
        linkViewFullPage.href = $galleryDoc.browseUrl
        linkViewFullPage.hidden = false
      }

      function init() {
        if (!$galleryDoc.hasContent()) {
          displayLink()

          PreviewContent.append($galleryDoc.url, $galleryDoc.embedContainer)
            .done(function (data) {
              reorderPreviewElements();
              scrollOver($galleryDoc.currentDocumentTarget(), $galleryDoc.galleryTarget)
            })
        }
      }

      function reorderPreviewElements() {
        var previewElements = $galleryDoc.embedContainer.find('.preview-container');
        $($galleryDoc.viewportTarget).append(previewElements);
      }
    })
  }

  Blacklight.onLoad(function () {
    $('*[data-behavior="embed-browse"]').embedBrowse()

    // Set up scroll behavior for tabs, when they are shown
    const tabs = document.querySelectorAll('button[data-bs-toggle="tab"]')
    tabs.forEach((tabEl) => {
      tabEl.addEventListener('shown.bs.tab', function (event) {
        const gallery = document.querySelector(`${event.target.dataset.bsTarget} .gallery`)
        const element = gallery.querySelector(`[data-doc-id="${event.target.dataset.start}"]`)
        scrollOver(element, gallery)
      })
    })
  })
})(jQuery);
