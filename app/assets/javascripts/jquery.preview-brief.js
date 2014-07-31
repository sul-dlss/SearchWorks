(function($) {

  /*
    jQuery plugin to attach preview triggers and render previews in
    brief view

      Usage: $(selector).previewBrief();

    This plugin :
      - adds preview triggers to the brief preview button
      - on preview click event, fetches preview content from
        'data-preview-url' data attribute value and renders it
  */


  $.fn.previewBrief = function() {

    return this.each(function() {
      var $item = $(this),
          previewClass = $item.data('preview-target'),
          $previewTarget = $(previewClass),
          previewUrl = $item.data('preview-url'),
          $triggerBtn, $briefTarget, briefCounter;

      init();
      attachTriggerEvents();

      function showPreview() {
        $previewTarget.addClass('preview').empty();

        // After preview content is appended, add the counter to the title
        $.when(PreviewContent.append(previewUrl, $previewTarget)).done(function(){
          $previewTarget.find('h3 a').before(briefCounter);
        });

        $triggerBtn
          .addClass('preview-open')
          .html('Close');

        $briefTarget.hide();
        $previewTarget.removeClass('hidden');
        $previewTarget.show();

      }


      function attachTriggerEvents() {
        $item.find($triggerBtn).on('click', function() {
          $(this).hasClass('preview-open') ? closePreview() : showPreview();
        });
      }

      function closePreview() {
        $previewTarget.removeClass('preview').hide();
        $briefTarget.show();

        $triggerBtn
          .removeClass('preview-open')
          .html('Preview');
      }

      function init() {
        briefCounter = $item.find('.document-counter').text();
        $triggerBtn = $item.find('*[data-behavior="preview-button-trigger"]');
        $briefTarget = $item.find('.brief-container .col-md-8');
      }

    });

  };

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-behavior="preview-brief"]').previewBrief();
});
