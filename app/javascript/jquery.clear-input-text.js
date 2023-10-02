(function($) {
  /*
    jQuery plugin to add clear text functionality to an input box

      Usage: $(selector).clearInputText();

    This plugin :
      - watches for text input event and shows/hides clear icon
      - clears text input when clear icon is clicked
  */

  $.fn.clearInputText = function() {

    return this.each(function() {
      var $input = $(this),
          $clearIcon = $('<a class="clear-input-text"><span class="sr-only">Clear search box</span><i class="fa fa-times-circle"></i></a>');

      init();
      attachEvents();

      function init() {
        $input.parent().prepend($clearIcon);
        $input.css('padding-right', $clearIcon.outerWidth());

        toggleClearIconVisibility($input);
        positionClearIcon();
      }

      function positionClearIcon() {
        $clearIcon.css({
          left: $input.position().left + $input.outerWidth() - $clearIcon.outerWidth(),
          'line-height': $input.outerHeight() + 'px'
        });
      }

      function attachEvents() {
        $input.on('input propertychange paste', function() {
          toggleClearIconVisibility($input);
        });

        $clearIcon.on('click', function() {
          $input.val('').focus();
          hideClearIcon();
        });

        $(window).resize(function() {
          positionClearIcon();
        });
      }

      function toggleClearIconVisibility($input) {
        $input.val().length > 0 ? showClearIcon() : hideClearIcon();
      }

      function hideClearIcon() {
        $clearIcon.css('visibility', 'hidden');
      }

      function showClearIcon() {
        $clearIcon.css('visibility', 'visible');
      }

    });
  }

})(jQuery);

Blacklight.onLoad(function() {
  $('#search-navbar input#q.search_q.q.form-control').clearInputText();
});
