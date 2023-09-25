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
    var $parent,
      booksPerAjaxCall = 15,
      booksApiUrl = 'https://books.google.com/books?jscmd=viewapi&bibkeys=',
      selectorCoverImg = 'img.cover-image',
      batches = [];

    function init() {
      var currentCovers = listCoverImgs();
      var totalCovers = currentCovers.length;

      // batch by batch-cutoff value
      while (totalCovers > 0) {
        batches.push(currentCovers.splice(0, booksPerAjaxCall));
        totalCovers = currentCovers.length;
      }

      addBookCoversByBatch();
    }

    function listCoverImgs() {
      return $parent.find(selectorCoverImg);
    }

    function addBookCoversByBatch() {
      $.each(batches, function(index, batch) {
        var bibkeys = getBibKeysForBatch(batch),
          batchBooksApiUrl = booksApiUrl + bibkeys;

        $.ajax({
          type: 'GET',
          url: batchBooksApiUrl,
          contentType: "application/json",
          dataType: 'jsonp',

          success: function(json) {
            renderCoverAndAccessPanel(json);
          },

          error: function(e) {
            console.log(e);
          }
        });

      });
    }

    function renderCoverAndAccessPanel(json) {
      // Loop through all the relevant cover elements and if the cover
      // element has a standard number (order of precidence: OCLC, LCCN, then ISBN)
      // that exists in the json response and render the cover image for it.
      $.each(listCoverImgs(), function(_, coverImg) {
        var data = bestResponseForNumber(json, coverImg);
        if (typeof data !== 'undefined') {
          renderCoverImage(data.bibkey, data.data);
          renderAccessPanel(data.bibkey, data.data);
        }
      });
    }

    function bestResponseForNumber(json, coverImg) {
      var data,
        $coverImg = $(coverImg),
        oclcKeys = $coverImg.data('oclc').split(','),
        lccnKeys = $coverImg.data('lccn').split(','),
        isbnKeys = $coverImg.data('isbn').split(',');
      $.each(oclcKeys, function(_, oclc) {
        if(json[oclc] && typeof json[oclc].thumbnail_url !== 'undefined') {
          data = { bibkey: oclc, data: json[oclc] };
          return false;
        }
      });
      if(typeof data === 'undefined') {
        $.each(lccnKeys, function(_, lccn) {
          if(json[lccn] && typeof json[lccn].thumbnail_url !== 'undefined') {
            data = { bibkey: lccn, data: json[lccn] };
            return false;
          }
        });
      }
      if(typeof data === 'undefined') {
        $.each(isbnKeys, function(_, isbn) {
          if(json[isbn] && typeof json[isbn].thumbnail_url !== 'undefined') {
            data = { bibkey: isbn, data: json[isbn] };
            return false;
          }
        });
      }
      return data;
    }

    function renderCoverImage(bibkey, data) {
      if (typeof data.thumbnail_url !== 'undefined') {
        var thumbUrl = data.thumbnail_url,
            selectorCoverImg = 'img.' + bibkey;

        thumbUrl = thumbUrl.replace(/zoom=5/, 'zoom=1');
        thumbUrl = thumbUrl.replace(/&?edge=curl/, '');

        var imageEl = $parent.find(selectorCoverImg);

        // Only set the thumb src if it's not already set
        if(typeof imageEl.attr('src') === 'undefined') {
          imageEl.attr('src', thumbUrl)[0].hidden = false;

          const fakeCover = imageEl.parent().parent().find('span.fake-cover')[0]
          if (fakeCover) {
            fakeCover.hidden = true
          }
        }
      }
    }


    function renderAccessPanel(bibkey, data) {
      if (typeof data.info_url !== 'undefined') {
        var listGoogleBooks = $.unique($parent.find('.google-books.' + bibkey));

        $.each(listGoogleBooks, function(i, googleBooks) {
          var $googleBooks = $(googleBooks),
            $fullView = $googleBooks.find('.full-view'),
            $limitedView = $googleBooks.find('.limited-preview');

          if (data.preview === 'full') {
            $fullView.attr('href', data.preview_url);
            checkAndEnableOnlineAccordionSection($googleBooks, $fullView);
            checkAndEnableAccessPanel($googleBooks, '.panel-online');
          } else if (data.preview === 'partial' || data.preview === 'noview') {
            $limitedView.attr('href', data.preview_url);
            checkAndEnableAccessPanel($googleBooks, '.panel-related');
          }
        });
      }
    }


    function getBibKeysForBatch(batch) {
      var bibkeys = '';

      $.each(batch, function(index) {
        var $CoverImg = $(this),
          isbn = $CoverImg.data('isbn') || '',
          oclc = $CoverImg.data('oclc') || '',
          lccn = $CoverImg.data('lccn') || '';

        bibkeys += [isbn, oclc, lccn].join(',') + ',';
      });

      bibkeys = bibkeys.replace(/,{2,}/, ','); // Replace 2 or more commas with a single
      bibkeys = bibkeys.replace(/^,/, ''); // Remove leading comma
      bibkeys = bibkeys.replace(/,$/, ''); // Remove trailing comma

      return bibkeys;
    }

    function checkAndEnableAccessPanel($googleBooks, selectorPanel) {
      var $accessPanel = $googleBooks.parents(selectorPanel);

      if ($accessPanel.length > 0) {
        $accessPanel[0].hidden = false;
        $googleBooks.show();
      }
    }

    function checkAndEnableOnlineAccordionSection($googleBooks, $fullViewLink) {
      $resultsOnlineSection = $googleBooks.parents('[data-behavior="results-online-section"]');

      if ($resultsOnlineSection.length > 0) {
        $resultsOnlineSection[0].hidden = false;
        $googleBooks[0].hidden = false;
        // Re-run responsive truncation on the list in case the google link takes us over the two-line threshold
        $googleBooks
          .parents("[data-behavior='truncate-results-metadata-links']")
          .responsiveTruncate({lines: 2, more: 'more...', less: 'less...'});
      }
    }

    return this.each(function() {
      $parent = $(this);
      init();
    });
  };

})(jQuery);

Blacklight.onLoad(function() {
  $('body').plugGoogleBookContent();
});
