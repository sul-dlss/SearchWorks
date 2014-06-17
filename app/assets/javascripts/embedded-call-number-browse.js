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

    GalleryDocs = function(item) {
      this.embedTarget = $(item.data('embed').target);
      this.startDoc = item.data('start');
      this.embedContainer = this.embedTarget.find('.gallery');
      this.url = item.data('url');
      this.docs = [];
      this.currentDoc = this.startDoc;
      this.waiting = false;
    };

    GalleryDocs.prototype.updateDocs = function() {
      this.docs = this.embedTarget.find('.gallery-document').map(function(){
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
      return this.embedTarget
        .find('.gallery-document[data-doc-id="' + this.currentDoc +'"]');
    };

    // Calculates the current document shown in the center
    GalleryDocs.prototype.getCurrent = function() {
      var pos = this.embedContainer.position()//.css('right');
      return ((pos.left-410)/194*-1);
    };

    // Returns the position of the $galleryDoc.currentDoc in $galleryDoc.docs
    GalleryDocs.prototype.currentPosition = function() {
      return $.inArray(this.currentDoc, this.docs);
    };

    return this.each(function() {
      var $item = $(this),
          $galleryDoc = new GalleryDocs($item),
          $embedScroll;
      init();

      function init() {
        $galleryDoc.embedTarget.on('shown.bs.collapse', function () {
          showPreview();
        });
        addListeners();
      }

      function showPreview() {
        if (!$galleryDoc.hasContent()){
          PreviewContent.append($galleryDoc.url, $galleryDoc.embedContainer)
            .done(function(data){
              $galleryDoc.updateDocs();
              $galleryDoc.currentDoc = $galleryDoc.docs[10];
              scrollOver(410);
          });
        }
      }

      // TODO disable side clicks when reaching end
      // TODO fix left scroll somehow, the problem is when divs are added to the left side,
      // the div automatically shifts
      // TODO fix preview positions and add plugin instantiation
      // TODO fix for various screen sizes

      function addListeners(){
        $galleryDoc.embedTarget.find('.embed-browse-control.right').on('click', function(e){
          e.preventDefault();
          processNext();
        });
        $galleryDoc.embedTarget.find('.embed-browse-control.left').on('click', function(e){
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

        $galleryDoc.embedTarget.find('.gallery').animate({
          right: left - 410
        });
      }

      function processPrevious() {
        var currentIndex;
        if ($galleryDoc.currentPosition() < 10 && !$galleryDoc.waiting){
          var numDocs = $galleryDoc.docs.length;
          getPrevious();
          updateWidth();
          currentIndex = $galleryDoc.currentPosition();
          $galleryDoc.currentDoc = $galleryDoc.docs[currentIndex - 5];
          if ($galleryDoc.currentDoc === undefined){
            $galleryDoc.currentDoc = $galleryDoc.docs[0];
          }
          if ($galleryDoc.docs.length === numDocs){
            scrollOver(410);
          }

          // TODO if docs dont change then scroll over!
        }else{
          currentIndex = $.inArray($galleryDoc.currentDoc, $galleryDoc.docs);
          $galleryDoc.currentDoc = $galleryDoc.docs[currentIndex - 5];
          if ($galleryDoc.currentDoc === undefined){
            $galleryDoc.currentDoc = $galleryDoc.docs[0];
          }
          scrollOver(410);
        }
      }

      function processNext() {
        if ($galleryDoc.docs.length - $galleryDoc.currentPosition() < 10){
          getNext();
          updateWidth();
        }
        var currentIndex = $.inArray($galleryDoc.currentDoc, $galleryDoc.docs);
        $galleryDoc.currentDoc = $galleryDoc.docs[currentIndex + 5];
        if ($galleryDoc.currentDoc === undefined){
          $galleryDoc.currentDoc = $galleryDoc.docs[$galleryDoc.docs.length-1];
        }
        scrollOver(410);
      }


      // Gets the next set of browse documents
      function getNext() {
        updateUrlStart($galleryDoc.docs[$galleryDoc.docs.length - 1]);
        updateUrlNext("right");
        PreviewContent.returnOnly($galleryDoc.url, $galleryDoc.embedContainer)
          .done(function(data){
            var lastDoc = $galleryDoc.embedTarget.find('.gallery-document:last');
            var newDocs = $(data).map(function(){
              return $(this).data('doc-id');
            });
            var alreadyIn = anyMatchInArray(newDocs, $galleryDoc.docs);

            // Add new docs after the last one only if the do not exist already.
            if (!alreadyIn){
              lastDoc.after(data).fadeIn();
            }

            // Update the array of gallery doc ids
            $galleryDoc.updateDocs();

            // Instantiate Google Book and filmstrip plugins
            $galleryDoc.embedContainer
              .plugGoogleBookContent()
              .find('.image-filmstrip').renderFilmstrip();
            Blacklight.do_bookmark_toggle_behavior();
        });
      }

      // Reverse a jQuery a selection
      jQuery.fn.reverse = [].reverse;

      // Gets the previous set of browse documents
      function getPrevious() {
        updateUrlStart($galleryDoc.docs[0]);
        updateUrlNext("left");
        PreviewContent.returnOnly($galleryDoc.url, $galleryDoc.embedContainer)
          .done(function(data){

            var firstDoc = $galleryDoc.embedTarget.find('.gallery-document:first');
            var newDocs = $(data);

            // WIP The way that new gallery items should be added to the beginning
            // of the div.
            newDocs.reverse().each(function(i,val){
              var item = $(this).hide().delay(40 * (i + 1)).fadeIn(function(){
                var current = $galleryDoc.docById().position().left
                $galleryDoc.embedTarget.find('.gallery').css({
                  right: (current - 410)
                });
              });
              firstDoc.before(item);

              $galleryDoc.updateDocs();
              var current = $galleryDoc.docById().position().left
              $galleryDoc.updateDocs();
            });
            $galleryDoc.updateDocs();
            $galleryDoc.embedContainer
              .plugGoogleBookContent()
              .find('.image-filmstrip').renderFilmstrip();
            Blacklight.do_bookmark_toggle_behavior();
        });
      }

      // Widen the .embedded-items div to accomodate new docs
      function updateWidth(){
        $galleryDoc.embedTarget.find('.embedded-items').width($galleryDoc.docs.length * 2 * 194);
      }

      // Updates start param for browse controller url
      function updateUrlStart(index) {
        $galleryDoc.url = $galleryDoc.url.replace(/\?start=[^&]+/, "?start=" + index );
      }

      // Updates the direction of the browse controller url
      function updateUrlNext(direction) {
        if ($galleryDoc.url.match(/\&next/)){
          $galleryDoc.url = $galleryDoc.url.replace(/\&next=[^&]+/, "&next=" + direction );
        }else{
          $galleryDoc.url += "&next=" + direction;
        }
      }

      // Returns true if any items are in the current array
      // from http://stackoverflow.com/questions/16312528/check-if-an-array-contains-any-elements-in-another-array-in-javascript
      var anyMatchInArray = function (target, toMatch) {
        "use strict";

        var found, targetMap, i, j, cur;
        found = false;
        targetMap = {};
        // Put all values in the `target` array into a map, where
        //  the keys are the values from the array
        for (i = 0, j = target.length; i < j; i++) {
            cur = target[i];
            targetMap[cur] = true;
        }
        // Loop over all items in the `toMatch` array and see if any of
        //  their values are in the map from before
        for (i = 0, j = toMatch.length; !found && (i < j); i++) {
            cur = toMatch[i];
            found = !!targetMap[cur];
            // If found, `targetMap[cur]` will return true, otherwise it
            //  will return `undefined`...that's what the `!!` is for
        }
          return found;
      };

    });

  };

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-behavior="embed-browse"]').embedBrowse();
});
