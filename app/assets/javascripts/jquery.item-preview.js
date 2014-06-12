(function($) {

  /*
    jQuery plugin to attach preview triggers and render previews

      Usage: $(selector).itemPreview();

    This plugin :
      - adds preview triggers to the matched elements
      - on preview click event, fetches preview content from
        'data-preview-url' data attribute value and renders it
      - for previews within a filmstrip, disables/enables
        filmstrip scrollbar on preview show/hide
  */


  $.fn.itemPreview = function() {

    return this.each(function() {
      var $item = $(this),
          $previewTarget = $($item.data('preview-target')),
          isPartOfFilmstrip = $item.data('preview-in-filmstrip') || false,
          showPointer = $item.data('preview-show-pointer') || true,
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
            arrowLeft;

        $previewTarget.addClass('preview').empty();

        appendPreviewContent(previewUrl, $previewTarget);

        if (showPointer) {
          appendPointer($previewTarget);
        }

        if (isPartOfFilmstrip) {
          $viewport.css('overflow-x', 'hidden');
        }

        $previewTarget.append($closeBtn).show();

        attachPreviewEvents();
      }


      function appendPreviewContent(url, $target) {
        var request = $.ajax({
          url: url,
          type: 'GET',
          dataType: 'html'
        });

        request.done(function(html) {
          $target.append($('<div class="preview-content"></div>').append(html));
        });

        request.fail(function(jqXhr, textStatus) {
          console.log('GET request for ' + url + ' failed: ' + textStatus);
        });
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

        if (isPartOfFilmstrip) {
          $filmstrip.find('.prev, .next').on('click', $.proxy(function() {
            closePreview();
          }, this));
        }
      }


      function attachPreviewEvents() {
        $previewTarget.find($closeBtn).on('click', $.proxy(function() {
          closePreview();
        }, this));
      }

      function closePreview() {
        if (isPartOfFilmstrip) {
          $viewport.css('overflow-x', 'scroll');
        }

        $previewTarget.empty().hide();
      }


      function init() {
        $triggerBtn = $('<div/>').addClass('preview-trigger-btn preview-opacity').html('<span class="glyphicon glyphicon-chevron-down small">');
        $triggerFocus = $('<div/>').addClass('preview-trigger-focus preview-opacity').html('Preview <span class="glyphicon glyphicon-chevron-down small">');
        $closeBtn = $('<a class="preview-close"><span class="glyphicon glyphicon-remove"></span></a>');
        $arrow = $('<div class="preview-arrow"></div>');

        if (isPartOfFilmstrip) {
          $filmstrip = $item.closest('.image-filmstrip');
          $viewport = $filmstrip.find('.viewport');
        }
      }

    });

  }

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-behavior="preview"]').itemPreview();
});

