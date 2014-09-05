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
      this.browseUrl = item.attr('href');
      this.docs = [];
      this.currentDoc = this.startDoc;
      this.updateHref();
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

    // Updates the href to activate plugin for javascript enabled browsers
    GalleryDocs.prototype.updateHref = function() {
      this.item.attr("href", this.item.data('embed-viewport'));
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
          $linkViewFullPage = $('.view-full-page a'),
          $embedScroll;
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
          $galleryDoc.embedViewport.slideDown(function(){
            $galleryDoc.calculateDocsPerView();
            showPreview();
          });
        }else{
          $galleryDoc.item.addClass('collapsed');
          $galleryDoc.embedViewport.slideUp(function(){
          });
        }
      }

      function showPreview() {
        if (!$galleryDoc.hasContent()){
          PreviewContent.append($galleryDoc.url, $galleryDoc.embedContainer)
            .done(function(data){
              $galleryDoc.updateDocs();
              scrollOver();
              Blacklight.do_bookmark_toggle_behavior();
              $(".gallery-document h3.index_title a").trunk8({ lines: 4 });
              reorderPreviewElements();
              $galleryDoc.embedContainer.find('*[data-behavior="preview-gallery"]').previewEmbedBrowse();
              $galleryDoc.addBrowseLinkDivs();
          });
        }
      }

      function reorderPreviewElements() {
        var previewElements = $galleryDoc.embedContainer.find('.preview-container');
        $galleryDoc.embedViewport.append(previewElements);
      }

      function addListeners() {
        $galleryDoc.embedViewport.find('.embed-browse-control.right').on('click', function(e){
          e.preventDefault();
          processNext();
        });
        $galleryDoc.embedViewport.find('.embed-browse-control.left').on('click', function(e){
          e.preventDefault();
          processPrevious();
        });

      }

      // Scroll to the current document
      function scrollOver(additional){
        var current = $galleryDoc.docById();
        var left;
        if (current.length){
          left = current.position().left;
        }else{
          console.log('could not get current position');
          return;
        }

        $galleryDoc.embedViewport.find('.gallery').animate({
          right: left - $galleryDoc.scrollOffset
        });
      }

      function processPrevious() {
        $galleryDoc.currentDoc = $galleryDoc.docs[$galleryDoc.currentPosition() - $galleryDoc.docsPerView];
        if ($galleryDoc.currentDoc === undefined){
          $galleryDoc.currentDoc = $galleryDoc.docs[0];
        }
        scrollOver();
      }

      function processNext() {
        var currentIndex = $.inArray($galleryDoc.currentDoc, $galleryDoc.docs);
        $galleryDoc.currentDoc = $galleryDoc.docs[currentIndex + $galleryDoc.docsPerView];
        if ($galleryDoc.currentDoc === undefined){
          $galleryDoc.currentDoc = $galleryDoc.docs[$galleryDoc.docs.length-1];
        }
        scrollOver();
      }
    });

  };

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-behavior="embed-browse"]').embedBrowse();
});
