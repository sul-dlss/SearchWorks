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
      var $elButton = $(this),
          $elToRotate,
          $parent,
          cssRotate90cw = 'search-navbar-dropdown-btn-rotate-90',
          cssRotate;

      cssRotate   = getRotateCssClass();
      $parent     = getParent();
      $elToRotate = getRotatableElement();

      $parent.on('show.bs.collapse', function() { $elToRotate.addClass(cssRotate); });
      $parent.on('show.bs.dropdown', function() { $elToRotate.addClass(cssRotate); });
      $parent.on('hide.bs.collapse', function() { $elToRotate.removeClass(cssRotate); });
      $parent.on('hide.bs.dropdown', function() { $elToRotate.removeClass(cssRotate); });

      function getParent() {
        var $parent = $elButton.parent(),
            $target = $($elButton.data('target'));

        if ($target.length !== 0) $parent = $target;

        return $parent;
      }

      function getRotatableElement() {
        var $elToRotate = $elButton,
            $elIcon = $elButton.find('.icon-to-rotate');

        if ($elIcon.length !== 0) $elToRotate = $elIcon;

        return $elToRotate;
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
