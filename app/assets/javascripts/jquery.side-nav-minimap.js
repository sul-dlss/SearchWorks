(function($) {

  /*
    jQuery plugin to enable side nav feature in  view
    Usage: $(selector).addSideBarNavInView();
  */

  $.fn.addSideNavMinimap = function() {
    var $sideNav = $('.side-nav-minimap');

    return this.each(function() {
      var $container = $('body');

      function init() {
        calculateAndAttachScrollEvents();
        positionSideNav();
        toggleSideNav();
      }

      function calculateAndAttachScrollEvents() {
        $sideNav.find('li button').each(function() {
          var $sideNavButton = $(this),
              $section = $container.find('#' + $sideNavButton.data('target-id'));

          if($section.length === 0) {
            $sideNavButton.hide();
            return;
          }

          var position = Math.round($section.offset().top);

          $section.legacyScrollspy({
            min: position,
            max: position + $(this).height(),
            onEnter: function(element, position) {
              highlightActiveButton($sideNavButton);
            }
          });

          $sideNavButton.on('click', function() {
            $(window).scrollTop($section.offset().top + 1);
            highlightActiveButton($(this));
          });
        });
      }

      function highlightActiveButton($button) {
        $sideNav.find('li button').removeClass('active');
        $button.addClass('active');
      }

      function positionSideNav() {
        var top = Math.round(($(window).height() - $sideNav.outerHeight()) / 2);
        $sideNav.css({ top: top + 'px' });
      }

      function toggleSideNav() {
        var hasScrollBar = document.body.scrollHeight > $('body').height();
        hasScrollBar ? $sideNav.show() : $sideNav.hide();
      }

      $(window).resize(function() {
        init();
      });

      init();
    });

  };

  function is_touch_device() {
    return (('ontouchstart' in window) || (navigator.MaxTouchPoints > 0) || (navigator.msMaxTouchPoints > 0));
  }


})(jQuery);

Blacklight.onLoad(function() {
  $('#content').addSideNavMinimap();
});
