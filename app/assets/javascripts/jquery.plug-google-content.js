(function($) {
  /*
    jQuery plugin to render Google book covers for image elements

      Usage: $(selector).renderGoogleBookCovers();

    This plugin :
      - collects all 'img.cover-image' elements and batches them
      - using ISBN, OCLC & LCCN value(s) of image elements inside each batch,
        Google cover images are added using Google Books API
  */

  $.fn.plugGoogleBookContent = function() {
    var $parent,
      booksPerAjaxCall = 25,
      booksApiUrl = 'https://books.google.com/books?jscmd=viewapi&bibkeys=',
      selectorCoverImg = 'img.cover-image',
      batches = [];

    function init() {
      var listCoverImgs = $parent.find(selectorCoverImg),
        totalCovers = listCoverImgs.length;

      // batch by batch-cutoff value
      while (totalCovers > 0) {
        batches.push(listCoverImgs.splice(0, booksPerAjaxCall));
        totalCovers = listCoverImgs.length;
      }

      addBookCoversByBatch();
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
      $.each(json, function(bibkey, data) {
        if (typeof data.thumbnail_url !== 'undefined') {
          renderCoverImage(bibkey, data);
          return;
        }
      });

      $.each(json, function(bibkey, data) {
        if (typeof data.info_url !== 'undefined') {
          renderAccessPanel(bibkey, data);
          return;
        }
      });
    }

    function renderCoverImage(bibkey, data) {
      var thumbUrl = data.thumbnail_url,
          selectorCoverImg = 'img.' + bibkey;

      thumbUrl = thumbUrl.replace(/zoom=5/, 'zoom=1');
      thumbUrl = thumbUrl.replace(/&?edge=curl/, '');

      var imageEl = $parent.find(selectorCoverImg);

      // Only set the thumb src if it's not already set
      if(typeof imageEl.attr('src') === 'undefined') {
        imageEl
          .attr('src', thumbUrl)
          .removeClass('hide')
          .addClass('show');

        imageEl.parent().parent().find('span.fake-cover')
          .addClass('hide');
      }
    }


    function renderAccessPanel(bibkey, data) {
      var listGoogleBooks = $.unique($parent.find('.google-books.' + bibkey));

      $.each(listGoogleBooks, function(i, googleBooks) {
        var $googleBooks = $(googleBooks),
          $fullView = $googleBooks.find('.full-view'),
          $limitedView = $googleBooks.find('.limited-preview');

        if (data.preview === 'full') {
          $fullView.attr('href', data.preview_url);
          checkAndEnableOnlineAccordionSection($googleBooks, $fullView);
          checkAndEnableAccessPanel($googleBooks, '.panel-online');
        } else if (data.preview === 'partial') {
          $limitedView.attr('href', data.preview_url);
          checkAndEnableAccessPanel($googleBooks, '.panel-related');
        }
      });

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

      bibkeys = bibkeys.replace(/,,/, '');
      bibkeys = bibkeys.replace(/,$/, '');

      return bibkeys;
    }

    function checkAndEnableAccessPanel($googleBooks, selectorPanel) {
      var $accessPanel = $googleBooks.parents(selectorPanel);

      if ($accessPanel.length > 0) {
        $accessPanel.removeClass('hide').addClass('show');
        $googleBooks.show();
      }
    }

    function checkAndEnableOnlineAccordionSection($googleBooks, $fullViewLink) {
      $accordionSection = $googleBooks.parents('.accordion-section');
      $snippet = $('.snippet', $accordionSection);

      if ($accordionSection.length > 0) {
        $accordionSection.removeClass('hide').addClass('show');
        $googleBooks.show();

        if ($.trim($snippet.text()) === "") {
          $snippet.html($fullViewLink.clone());
        }
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
