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
      this.embedContainer = this.embedViewport.find('.gallery');
      this.url = item.data('url');
      this.browseUrl = item.data('index-path');
      this.currentDoc = item.data('start')
    };

    GalleryDocs.prototype.docs = function() {
      return this.embedViewport.find('.gallery-document')
    };

    GalleryDocs.prototype.hasContent = function() {
      return this.docs().length !== 0
    }

    GalleryDocs.prototype.docById = function() {
      return this.embedViewport
        .find(`.gallery-document[data-doc-id="${this.currentDoc}"]`)
    };

    // Calculates how many docs can be viewed in the viewport
    GalleryDocs.prototype.calculateDocsPerView = function() {
      var width = $(this.embedViewport).outerWidth();
      this.docsPerView = Math.floor(width/DOC_WIDTH);
      this.scrollOffset = (width/2) - (DOC_WIDTH/2) - DOC_WIDTH;
    };

    GalleryDocs.prototype.addBrowseLinkDivs = function() {
      let html = `<div class="gallery-document"><div class="browse-link">` +
                 `<a href="${this.browseUrl}" class="text-center"> Continue to full page</a></div></div>`
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

        // It's possible the page was restored from a turbo cache, where the panel was already open.
        // We don't want to toggle it closed.
        $('[data-behavior="embed-browse"].collapsed').first().click();
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
              // just like Blacklight's doBookmarkToggleBehavior, but scoped to the embed container so we don't
              // try to set the behavior multiple times
              $('.embed-callnumber-browse-container').find(Blacklight.doBookmarkToggleBehavior.selector).blCheckboxSubmit({
                 // cssClass is added to elements as a css class, but it is also used for generating an identifier.
                 // Therefore, we don't want to use the default 'toggle-bookmark', but we will use something unique,
                 // so that the browse documents don't have an id collision with the parent document.
                 cssClass: 'browse-toggle-bookmark',
                 success: function(checked, response) {
                   if (response.bookmarks) {
                     $('[data-role=bookmark-counter]').text(response.bookmarks.count);
                   }
                 }
              });

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
