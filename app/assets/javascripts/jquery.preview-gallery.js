(function($) {

  /*
    jQuery plugin to attach gallery preview triggers and render previews in
    gallery view

      Usage: $(selector).previewGallery();

    This plugin :
      - adds preview triggers to the gallery preview button
      - on preview click event, fetches preview content from
        'data-preview-url' data attribute value and renders it
  */


  $.fn.previewGallery = function() {

    return this.each(function() {
      var $item = $(this),
          $previewTarget = $($item.data('preview-target')),
          $triggerBtn, $closeBtn, $arrow, $gallery, $itemsPerRow, $itemWidth;

      init();
      attachTriggerEvents();

      function showPreview() {
        var previewUrl = $item.data('preview-url')

        $previewTarget.addClass('preview').empty();

        PreviewContent.append(previewUrl, $previewTarget);

        appendPointer($previewTarget);

        $previewTarget.css('display', 'inline-block');

        $previewTarget.append($closeBtn).show();

        $triggerBtn.html('Close');

        attachPreviewEvents();

        $triggerBtn.addClass('preview-open');
      }

      function clamp(x, min, max) {
        return Math.min(Math.max(x, min), max);
      }

      function appendPointer($target) {
        $target.append($arrow);

        const maxLeft = $target.width() - $arrow.width() - 1
        const { left, width } = $item[0].getBoundingClientRect()
        const docsLeft = document.getElementById('documents').getBoundingClientRect().left
        const arrowLeft = clamp(left - docsLeft + width / 2 - 10, 0, maxLeft)

        $arrow.css('left', arrowLeft);
      }


      function attachTriggerEvents() {
        $item.find($triggerBtn).on('click', $.proxy(function(e) {
          if (previewOpen()){
            closePreview();
          }else{
            showPreview();
          }
        }, this));

        $("#documents").on('click', $.proxy(function(e) {
          if (!currentPreview(e)){
            closePreview();
          }
        }, this));
      }

      function currentPreview(e){
        // Check if we're clicking in a preview
        if ($(e.target).parents('.preview-container').length > 0){
          return true;
        }else{
          if (e.target === $triggerBtn[0]) {
            return true;
          }else{
            return false;
          }
        }
      }

      function previewOpen(){
        if ($triggerBtn.hasClass('preview-open')){
          return true;
        }else{
          return false;
        }
      }



      function attachPreviewEvents() {
        $previewTarget.find($closeBtn).on('click', $.proxy(function() {
          closePreview();
        }, this));
      }

      function closePreview() {
        $previewTarget.removeClass('preview');
        $triggerBtn.removeClass('preview-open');
        $previewTarget.hide();
        $triggerBtn.html('Preview');
      }

      function itemsPerRow() {
        var width = $('#documents').width();
        return  Math.floor(width/$itemWidth);
      }

      function reorderPreviewDivs() {
        var previewDivs = $('.preview-container');
        var previewIndex = previewDivs.index($previewTarget) + 1;
        $itemsPerRow = itemsPerRow();
        /* 
        / If $itemsPerRow is NaN or 0 we should return here. If not we are going 
        / to have a bad time with an infinite while loop. This only manifests
        / on the show page when using the "back" button to get back to a show
        / page using the browse nearby feature.
        */
        if ($itemsPerRow === NaN || $itemsPerRow === 0) {
          return;
        }

        if (previewIndex % $itemsPerRow !== 0){
          while (previewIndex % $itemsPerRow !== 0){
            previewIndex++;
          }
          if (previewIndex > previewDivs.length){
            previewIndex = previewDivs.length;
          }
          var detachedPreview = $previewTarget.detach();
          $($gallery[(previewIndex-1)]).after($previewTarget);
        }
      }


      function init() {
        $itemWidth = $item.outerWidth() + 10;
        $triggerBtn = $item.find('*[data-behavior="preview-button-trigger"]');
        $closeBtn = $(`<button type="button" class="preview-close btn-close close" aria-label="Close">
        <span aria-hidden="true" class="visually-hidden">×</span>
        </button>`);
        $arrow = $('<div class="preview-arrow"></div>');
        $gallery = $('.gallery-document');
        reorderPreviewDivs();
      }

    });

  };

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-behavior="preview-gallery"]').previewGallery();
});
