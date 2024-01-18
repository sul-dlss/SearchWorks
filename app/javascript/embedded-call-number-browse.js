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


  $.fn.embedBrowse = function() {

    var DOC_WIDTH = 194;

    GalleryDocs = function(item) {
      this.item = item;
      this.embedViewport = $(item.data('embed-viewport'));
      this.startDoc = item.data('start');
      this.embedContainer = this.embedViewport.find('.gallery');
      this.url = item.data('url');
      this.browseUrl = item.data('index-path');
      this.docs = [];
      this.currentDoc = this.startDoc;
    };

    GalleryDocs.prototype.updateDocs = function() {
      this.docs = this.embedViewport.find('.gallery-document').map(function(){
        return $(this).data('doc-id');
      });
    };

    GalleryDocs.prototype.hasContent = function() {
      if (this.docs.length){
        return true;
      }else{
        return false;
      }
    };

    GalleryDocs.prototype.docById = function() {
      return this.embedViewport
        .find('.gallery-document[data-doc-id="' + this.currentDoc +'"]');
    };

    // Returns the position of the $galleryDoc.currentDoc in $galleryDoc.docs
    GalleryDocs.prototype.currentPosition = function() {
      return $.inArray(this.currentDoc, this.docs);
    };

    // Calculates how many docs can be viewed in the viewport
    GalleryDocs.prototype.calculateDocsPerView = function() {
      var width = $(this.embedViewport).outerWidth();
      this.docsPerView = Math.floor(width/DOC_WIDTH);
      this.scrollOffset = (width/2) - (DOC_WIDTH/2) - DOC_WIDTH;
    };

    GalleryDocs.prototype.addBrowseLinkDivs = function() {
      var html = '<div class="gallery-document"><div class="browse-link"><a href="';
      html += this.browseUrl;
      html +=  '">Continue to full page</a></div></div>';
      this.embedContainer.append(html);
      this.embedContainer.prepend(html);
    };

    return this.each(function() {
      var $item = $(this),
          $galleryDoc = new GalleryDocs($item),
          $linkViewFullPage = $('.view-full-page a');

      init();

      function init() {
        $galleryDoc.item.on('click', function(e){
          e.preventDefault();
          $linkViewFullPage.attr('href', $galleryDoc.browseUrl);
          closeOtherBrowsers();
          openThisBrowser();
        });

        addListeners();
        $('[data-behavior="embed-browse"]').first().click();
      }

      function closeOtherBrowsers() {
        $('[data-behavior="embed-browse"]').each(function(i,val){
          var button = $(val);
          button.removeClass('active');
          if (button[0] !== $galleryDoc.item[0]){
            if (button.hasClass('collapsed')){
              return;
            }else{
              button.trigger('click');
            }
          }
        });
      }

      function openThisBrowser() {
        if ($galleryDoc.item.hasClass('collapsed')){
          $galleryDoc.item.removeClass('collapsed').addClass('active');
          $galleryDoc.item.attr('aria-expanded', 'true');
          $galleryDoc.embedViewport.attr('aria-expanded', 'true');
          $galleryDoc.embedViewport.slideDown(function(){
            $galleryDoc.calculateDocsPerView();
            showPreview();
          });
        } else {
          $galleryDoc.item.addClass('collapsed');
          $galleryDoc.item.attr('aria-expanded', 'false');
          $galleryDoc.embedViewport.slideUp(function(){
          });
          $galleryDoc.embedViewport.attr('aria-expanded', 'false');
        }
      }

      function showPreview() {
        if (!$galleryDoc.hasContent()){
          PreviewContent.append($galleryDoc.url, $galleryDoc.embedContainer)
            .done(function(data){
              $galleryDoc.updateDocs();

              // fix up the id/for to avoid duplicating html ids for the current document.
              $('.gallery-document label.toggle-bookmark').each(function(i, val) {
                var id = 'browse_' + val.attr('for');
                val.attr('for', id);
                val.first('input').attr('id', id);
              });

              // just like Blacklight's doBookmarkToggleBehavior, but scoped to the embed container so we don't
              // try to set the behavior multiple times
              $('.embed-callnumber-browse-container').find(Blacklight.doBookmarkToggleBehavior.selector).blCheckboxSubmit({
                 // cssClass is added to elements added, plus used for id base
                 cssClass: 'toggle-bookmark',
                 success: function(checked, response) {
                   if (response.bookmarks) {
                     $('[data-role=bookmark-counter]').text(response.bookmarks.count);
                   }
                 }
              });

              $(".gallery-document h3.index_title a").trunk8({ lines: 4 });
              reorderPreviewElements();
              $galleryDoc.embedContainer.find('*[data-behavior="preview-gallery"]').previewEmbedBrowse();
              $galleryDoc.addBrowseLinkDivs();
              scrollOver();
          });
        }
      }

      function reorderPreviewElements() {
        var previewElements = $galleryDoc.embedContainer.find('.preview-container');
        $galleryDoc.embedViewport.append(previewElements);
      }

      function addListeners() {
      }

      // Scroll to the current document
      function scrollOver(){
        var current = $galleryDoc.docById();
        var scrollAmount;
        if (current.length){
          scrollAmount = current.position().left - current.parent().width()/2 + current.innerWidth()/2;
        }else{
          return;
        }

        current.addClass('current-document');
        $galleryDoc.embedViewport.find('.gallery').animate({
          scrollLeft: scrollAmount
        }, 200);
      }
    });

  };

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-behavior="embed-browse"]').embedBrowse();
});
