(function($) {
  /*
    jQuery plugin to toggle annotation forms

      Usage: $(selector).toggleAnnotationsForm();

    This plugin :
      - toggles tag and comment forms in search results and record view
  */

  $.fn.toggleAnnotationsForm = function() {

    return this.each(function() {
      var $container = $(this),
          $formAnnotations = $container.find('.form-annotations');

      init();

      function init() {
        $container.parent().find('.btn-add-annotation').on('click', function() {
          $formAnnotations.parent().slideToggle('fast');
          $formAnnotations.find('.text-annotation').focus();
        });

        $container.find('a.cancel-link').on('click', function(event) {
          $formAnnotations.parent().slideUp('fast');
          $formAnnotations.find('.text-annotation').blur();
          event.preventDefault();
        });

      }

    });
  };

})(jQuery);

Blacklight.onLoad(function() {
  $('#create-tag').toggleAnnotationsForm();
  $('#create-comment').toggleAnnotationsForm();
});
