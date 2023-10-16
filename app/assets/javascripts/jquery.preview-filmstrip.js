(function($) {

  /*
    jQuery plugin to attach preview triggers and render previews

      Usage: $(selector).previewFilmstrip();

    This plugin :
      - adds preview triggers to the matched elements
      - on preview click event, fetches preview content from
        'data-preview-url' data attribute value and renders it
      - for previews within a filmstrip, disables/enables
        filmstrip scrollbar on preview show/hide
  */


  $.fn.previewFilmstrip = function() {

    return this.each(function() {
      var $item = $(this),
          $previewTarget = $($item.data('preview-target')),
          showPointer = true,
          $triggerBtn, $triggerFocus, $closeBtn, $arrow, $content, $filmstrip, $viewport;

      init();
      appendTriggers();

      function appendTriggers() {
        $item.append($triggerBtn).append($triggerFocus);
        attachTriggerEvents();
      }


      function showPreview() {
        var previewUrl = $item.data('preview-url'),
            $previewArrow,
            maxLeft,
            arrowLeft,
            $divContent = $('<div class="preview-content"></div>');

        $previewTarget.addClass('preview').empty();

        if (showPointer) {
          appendPointer($previewTarget);
        }

        PreviewContent.append(previewUrl, $divContent);

        $previewTarget
          .append($divContent)
          .append($closeBtn)
          .show();

        $viewport.css('overflow-x', 'hidden');

        attachPreviewEvents();
      }


      function appendPointer($target) {
        $target.append($arrow);

        maxLeft = $target.width() - $arrow.width() - 1,
        arrowLeft = parseInt($item.position().left + ($item.width()/2) - 20);

        if (arrowLeft < 0) arrowLeft = 0;
        if (arrowLeft > maxLeft) arrowLeft = maxLeft;

        $arrow.css('left', arrowLeft);
      }


      function attachTriggerEvents() {
        $item.on('mouseenter', function() {
          $(this).find($triggerBtn).hide();
          $(this).find($triggerFocus).fadeIn('fast');
        });

        $item.on('mouseleave', function() {
          $(this).find($triggerFocus).hide();
          $(this).find($triggerBtn).show();
        });

        $item.find($triggerBtn).on('click', $.proxy(function(e) {
          showPreview();
        }, this));

        $item.find($triggerFocus).on('click', $.proxy(function(e) {
          showPreview();
        }, this));

        $filmstrip.find('.prev, .next').on('click', $.proxy(function() {
          closePreview();
        }, this));
      }


      function attachPreviewEvents() {
        $previewTarget.find($closeBtn).on('click', $.proxy(function() {
          closePreview();
        }, this));
      }

      function closePreview() {
        $viewport.css('overflow-x', 'scroll');
        $previewTarget.empty().hide();
      }


      function init() {
        $triggerBtn = $('<div/>').addClass('preview-trigger-btn preview-opacity').html('<span class="bi-chevron-down small">');
        $triggerFocus = $('<div/>').addClass('preview-trigger-focus preview-opacity').html('Preview <span class="bi-chevron-down small">');
        $closeBtn = $(`<button type="button" class="preview-close btn-close close" aria-label="Close">
        <span aria-hidden="true" class="visually-hidden">×</span>
        </button>`);
        $arrow = $('<div class="preview-arrow"></div>');
        $filmstrip = $item.closest('.image-filmstrip');
        $viewport = $filmstrip.find('.viewport');
      }

    });

  }

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-behavior="preview-filmstrip"]').previewFilmstrip();
});
