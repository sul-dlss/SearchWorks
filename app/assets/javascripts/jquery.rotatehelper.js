(function($) {
  /*
    jQuery plugin to rotate an icon inside a Bootstrap dropdown

      Usage: $(selector).rotateHelper(option);

    Available option values = '90cw' [default]

    This plugin :
      - listens for '[show|hide].bs[collapse|dropdown]' event on callee's
        parent or element specified in 'data-target' attribute
      - rotates callee or child element with class 'icon-to-rotate' using
        specified option
  */

  $.fn.rotateHelper = function(rotate) {
    return this.each(function() {
      var $button = $(this),
          $toRotate,
          $parent,
          cssRotate90cw = 'search-navbar-dropdown-btn-rotate-90',
          cssRotate;

      cssRotate   = getRotateCssClass();
      $parent     = getParent();
      $toRotate = getRotatableElement();

      $parent.on('show.bs.collapse', function() { $toRotate.addClass(cssRotate); });
      $parent.on('show.bs.dropdown', function() { $toRotate.addClass(cssRotate); });
      $parent.on('hide.bs.collapse', function() { $toRotate.removeClass(cssRotate); });
      $parent.on('hide.bs.dropdown', function() { $toRotate.removeClass(cssRotate); });

      function getParent() {
        var $parent = $button.parent(),
            $target = $($button.data('target'));

        if ($target.length !== 0) $parent = $target;

        return $parent;
      }

      function getRotatableElement() {
        var $toRotate = $button,
            $Icon = $button.find('.icon-to-rotate');

        if ($Icon.length !== 0) $toRotate = $Icon;

        return $toRotate;
      }

      function getRotateCssClass() {
        cssRotate = cssRotate90cw; // default

        if (typeof rotate !== 'undefined') {
          if (rotate === '90cw') cssRotate = cssRotate90cw;
        }

        return cssRotate;
      }

    });
  }

})(jQuery);
