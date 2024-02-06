import PreviewContent from './preview-content'

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
      let $item = $(this),
          previewClass = $item.data('preview-target'),
          previewUrl = $item.data('preview-url'),
          $triggerBtn;
      const previewTarget = document.querySelector(previewClass)

      init();
      attachTriggerEvents();

      function showPreview() {
        previewTarget.classList.add('preview')
        previewTarget.innerHTML = '<div class="preview-arrow"></div>'

        PreviewContent.append(previewUrl, $(previewTarget));

        $triggerBtn
          .addClass('preview-open')
          .html('Close');

        previewTarget.classList.remove('hidden')
      }

      function attachTriggerEvents() {
        $item.find($triggerBtn).on('click', function() {
          $(this).hasClass('preview-open') ? closePreview() : showPreview();
        });
      }

      function closePreview() {
        previewTarget.classList.remove('preview')

        $triggerBtn
          .removeClass('preview-open')
          .html('Preview');
      }

      function init() {
        $triggerBtn = $item.find('*[data-behavior="preview-button-trigger"]');
      }

    });

  };

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-behavior="preview-brief"]').previewBrief();
});
