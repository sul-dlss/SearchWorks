import PreviewContent from './preview-content'

(function($) {

  /*
    jQuery plugin to attach gallery preview triggers and render previews while
    in the embedded callnumber browse

      Usage: $(selector).previewEmbedBrowse();

    This plugin :
      - adds preview triggers to the gallery preview button
      - on preview click event, fetches preview content from
        'data-preview-url' data attribute value and renders it
      - reorders all of the preview divs to the end of the embedded gallery
  */


  $.fn.previewEmbedBrowse = function() {

    return this.each(function() {
      const $item = $(this)
      const $previewTarget = $($item.data('preview-target'))
      const $triggerBtn = $item.find('*[data-behavior="preview-button-trigger"]');
      const $closeBtn = $(`<button type="button" class="preview-close btn-close close" aria-label="Close">
        <span aria-hidden="true" class="visually-hidden">×</span>
        </button>`)
      const $arrow = $('<div class="preview-arrow"></div>');

      attachTriggerEvents();

      function showPreview() {
        const previewUrl = $item.data('preview-url')
        $previewTarget.addClass('preview').empty()
        PreviewContent.append(previewUrl, $previewTarget);
        $previewTarget.css('display', 'inline-block');
        $previewTarget.append($closeBtn).show();
        appendPointer($previewTarget);
        $triggerBtn.html('Close');
        attachPreviewEvents();
        $triggerBtn.addClass('preview-open');
      }

      function appendPointer($target) {
        $target.append($arrow);

        const maxLeft = $target.width() - $arrow.width() - 1
        let arrowLeft = parseInt($item.offset().left + ($item.width()/2) - $target.offset().left);

        if (arrowLeft < 0) arrowLeft = 0;
        if (arrowLeft > maxLeft) arrowLeft = maxLeft;

        $arrow.css('left', arrowLeft);
      }

      function attachTriggerEvents() {
        $item.find($triggerBtn).on('click', $.proxy(function(e) {
          if (previewOpen()){
            closePreview()
          } else {
            showPreview()
          }
        }, this));

        $("#content").on('click', $.proxy(function(e) {
          if (!currentPreview(e) && (typeof $(e.target).data('accordion-section-target') === 'undefined')){
              closePreview();
          }

        }, this));
      }

      function currentPreview(e){
        // Check if we're clicking in a preview
        if ($(e.target).parents('.preview-container').length > 0){
          return true;
        } else {
          return e.target === $triggerBtn[0]
        }
      }

      function previewOpen(){
        return $triggerBtn.hasClass('preview-open')
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
    })
  }
})(jQuery);
