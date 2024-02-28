(function($) {
  /*
    jQuery plugin to render Google book covers for image elements

      Usage: $(selector).plugGoogleBookContent();

    This plugin :
      - collects all 'img.cover-image' elements and batches them
      - using ISBN, OCLC & LCCN value(s) of image elements inside each batch,
        Google cover images are added using Google Books API
  */

  $.fn.plugGoogleBookContent = function() {
    let parent
    const booksPerAjaxCall = 15
    const booksApiUrl = 'https://books.google.com/books?jscmd=viewapi&bibkeys='
    const selectorCoverImg = 'img.cover-image'
    const batches = []

    function init() {
      const currentCovers = Array.from(listCoverImgs())
      let totalCovers = currentCovers.length;

      // batch by batch-cutoff value
      while (totalCovers > 0) {
        batches.push(currentCovers.splice(0, booksPerAjaxCall))
        totalCovers = currentCovers.length
      }

      addBookCoversByBatch();
    }

    function listCoverImgs() {
      return parent.querySelectorAll(selectorCoverImg);
    }

    function addBookCoversByBatch() {
      batches.forEach((batch) => {
        const bibkeys = getBibKeysForBatch(batch)
        const batchBooksApiUrl = booksApiUrl + bibkeys

        $.ajax({
          type: 'GET',
          url: batchBooksApiUrl,
          contentType: "application/json",
          dataType: 'jsonp',

          success: function(json) {
            renderCoverAndAccessPanel(json);
          },

          error: function(e) {
            console.error(e);
          }
        });

      });
    }

    function renderCoverAndAccessPanel(json) {
      // Loop through all the relevant cover elements and if the cover
      // element has a standard number (order of precidence: OCLC, LCCN, then ISBN)
      // that exists in the json response and render the cover image for it.
      listCoverImgs().forEach((coverImg) => {
        const data = bestResponseForNumber(json, coverImg);
        if (typeof data !== 'undefined') {
          renderCoverImage(data.bibkey, data.data);
          renderAccessPanel(data.bibkey, data.data);
        }
      });
    }

    function bestResponseForNumber(json, coverImg) {
      let data
      const $coverImg = $(coverImg)
      const oclcKeys = $coverImg.data('oclc').split(',')
      const lccnKeys = $coverImg.data('lccn').split(',')
      const isbnKeys = $coverImg.data('isbn').split(',')
      oclcKeys.forEach((oclc) => {
        if (json[oclc] && typeof json[oclc].thumbnail_url !== 'undefined') {
          data = { bibkey: oclc, data: json[oclc] }
          return
        }
      })
      if (typeof data === 'undefined') {
        lccnKeys.forEach((lccn) => {
          if (json[lccn] && typeof json[lccn].thumbnail_url !== 'undefined') {
            data = { bibkey: lccn, data: json[lccn] }
            return
          }
        })
      }
      if (typeof data === 'undefined') {
        isbnKeys.forEach((isbn) => {
          if (json[isbn] && typeof json[isbn].thumbnail_url !== 'undefined') {
            data = { bibkey: isbn, data: json[isbn] }
            return
          }
        })
      }
      return data
    }

    function renderCoverImage(bibkey, data) {
      if (typeof data.thumbnail_url !== 'undefined') {
        let thumbUrl = data.thumbnail_url
        const selectorCoverImg = `img.${bibkey}`

        thumbUrl = thumbUrl.replace(/zoom=5/, 'zoom=1')
        thumbUrl = thumbUrl.replace(/&?edge=curl/, '')

        const imageEl = parent.querySelector(selectorCoverImg)

        // Only set the thumb src if it's not already set
        if (imageEl.src === '') {
          imageEl.src = thumbUrl
          imageEl.hidden = false

          const fakeCover = imageEl.parentElement.querySelector('span.fake-cover')
          if (fakeCover) {
            fakeCover.hidden = true
          }
        }
      }
    }


    function renderAccessPanel(bibkey, data) {
      if (typeof data.info_url !== 'undefined') {
        const listGoogleBooks = parent.querySelectorAll(`.google-books.${bibkey}`)

        listGoogleBooks.forEach((googleBooks) => {
          const $googleBooks = $(googleBooks)
          if (data.preview === 'full') {
            const $fullView = $googleBooks.find('.full-view')
            $fullView.attr('href', data.preview_url);
            checkAndEnableOnlineAccordionSection($googleBooks, $fullView);
            checkAndEnableAccessPanel($googleBooks, '.panel-online');
          } else if (data.preview === 'partial' || data.preview === 'noview') {
            const $limitedView = $googleBooks.find('.limited-preview')
            $limitedView.attr('href', data.preview_url);
            checkAndEnableAccessPanel($googleBooks, '.panel-related');
          }
        });
      }
    }

    // Return a comma delimited string of identifiers
    function getBibKeysForBatch(batch) {
      return batch.flatMap((coverImg) => {
        const isbn = coverImg.dataset.isbn.split(',')
        const oclc = coverImg.dataset.oclc.split(',')
        const lccn = coverImg.dataset.lccn.split(',')

        return isbn.concat(oclc).concat(lccn)
      }).filter(elm => elm).join(',')
    }

    function checkAndEnableAccessPanel($googleBooks, selectorPanel) {
      const $accessPanel = $googleBooks.parents(selectorPanel);

      if ($accessPanel.length > 0) {
        $accessPanel[0].hidden = false
        $googleBooks.show()
      }
    }

    function checkAndEnableOnlineAccordionSection($googleBooks, $fullViewLink) {
      $resultsOnlineSection = $googleBooks.parents('[data-behavior="results-online-section"]');

      if ($resultsOnlineSection.length > 0) {
        $resultsOnlineSection[0].hidden = false
        $googleBooks[0].hidden = false
        // Re-run responsive truncation on the list in case the google link takes us over the two-line threshold
        $googleBooks
          .parents("[data-behavior='truncate-results-metadata-links']")
          .responsiveTruncate({lines: 2, more: 'more...', less: 'less...'})
      }
    }

    return this.each(function() {
      parent = this
      init()
    })
  }

})(jQuery)

Blacklight.onLoad(function() {
  $('body').plugGoogleBookContent()
});
