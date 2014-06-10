(function($) {
  /*
    jQuery plugin to render Google book covers for image elements

      Usage: $(selector).imgFilmStrip();

    This plugin :
      - renders filmstrip view for elements with 'image-filmstrip' class
        and attaches navigation events
  */

  $.fn.imgPreview = function() {

    return this.each(function() {
      var $containerPreviews = $(this),
          $previewSources = [],
          $previews,
          isPartOfFilmstrip = false,
          $viewport;

      init();

      function init() {
        $previews = $containerPreviews.find('.preview');

        setValuesIfPartOfFilmstrip();
        appendPreviewTriggers();
        attachEvents();
      }

      function appendPreviewTriggers() {
        $previews.each(function(index, preview) {
          var previewId = $(preview).data('previewId'),
              $previewSource = $('.preview-source-' + previewId),

              $triggerBtn = $('<div/>')
                .addClass('preview-trigger-btn preview-opacity')
                .html('<span class="glyphicon glyphicon-chevron-down small">'),
              $triggerFocus = $('<div/>')
                .addClass('preview-trigger-focus preview-opacity')
                .html('Preview <span class="glyphicon glyphicon-chevron-down small">');

          $triggerBtn.data('preview-id', previewId);
          $triggerFocus.data('preview-id', previewId);

          $previewSource.append($triggerBtn).append($triggerFocus);
          $previewSources.push($previewSource);
        });
      }


      function showPreview(previewId) {
        var $previewSource = $('.preview-source-' + previewId),
            $previewTarget = $containerPreviews.find('.preview-target-' + previewId),
            $previewArrow  = $previewTarget.find('.preview-arrow'),
            $previewImg    = $previewTarget.find('a img.preview-img'),
            maxLeft = $containerPreviews.width() - $previewArrow.width() - 1,
            arrowLeft = parseInt($previewSource.position().left + ($previewSource.width()/2) - 20);

        if (arrowLeft < 0) arrowLeft = 0;
        if (arrowLeft > maxLeft) arrowLeft = maxLeft;

        if (isPartOfFilmstrip) {
          $viewport.css('overflow-x', 'hidden');
        }

        $previewArrow.css('left', arrowLeft);

        if ($previewImg.length > 0) {
          $previewImg.attr('src', $previewImg.data('url'));
        }

        $previews.hide();
        $previewTarget.show();
      }

      function closePreviews() {
        if (isPartOfFilmstrip) {
          $viewport.css('overflow-x', 'scroll');
        }

        $previews.hide();
      }


      function attachEvents() {
        $.each($previewSources, function(index, $previewSource) {
          $previewSource.on('mouseenter', function() {
            $(this).find('.preview-trigger-btn').hide();
            $(this).find('.preview-trigger-focus').fadeIn('fast');
          });

          $previewSource.on('mouseleave', function() {
            $(this).find('.preview-trigger-focus').hide();
            $(this).find('.preview-trigger-btn').show();
          });

          $previewSource.find('.preview-trigger-btn, .preview-trigger-focus').on('click', $.proxy(function(e) {
            showPreview($(e.target).data('preview-id'));
          }, this));
        });

        $containerPreviews.find('.preview-close').on('click', $.proxy(function() {
          closePreviews();
        }, this));

        if (isPartOfFilmstrip) {
          $viewport.parent('.image-filmstrip').find('.prev, .next').on('click', $.proxy(function() {
            closePreviews();
          }, this));
        }
      }


      function setValuesIfPartOfFilmstrip() {
        if (typeof $containerPreviews.data('type') !== undefined && $containerPreviews.data('type') === 'filmstrip') {
          $viewport = $containerPreviews.parent('.image-filmstrip').find('.viewport');
          isPartOfFilmstrip = true;
        }
      }

    });

  }

})(jQuery);


Blacklight.onLoad(function() {
  $('.container-previews').imgPreview();
});
