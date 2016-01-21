(function($) {

  /*
    jQuery plugin to enable side nav feature in record view
    Usage: $(selector).addSideBarNavInRecordView();
  */

  $.fn.addSideBarNavInRecordView = function() {
    var $recordSideNav = $('.record-side-nav');

    return this.each(function() {
      var $container = $('body');

      function init() {
        calculateAndAttachScrollEvents();
        positionSideNav();
        toggleSideNav();
      }

      function calculateAndAttachScrollEvents() {
        $recordSideNav.find('li button').each(function() {
          var $sideNavButton = $(this),
              $section = $container.find('#' + $sideNavButton.data('target-id')),
              position = Math.round($section.offset().top);

          $section.scrollspy({
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
        $recordSideNav.find('li button').removeClass('active');
        $button.addClass('active');
      }

      function positionSideNav() {
        var top = Math.round(($(window).height() - $recordSideNav.outerHeight()) / 2);
        $recordSideNav.css({ top: top + 'px' });
      }

      function toggleSideNav() {
        var hasScrollBar = document.body.scrollHeight > $('body').height();
        hasScrollBar ? $recordSideNav.show() : $recordSideNav.hide();
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
  $('#document').addSideBarNavInRecordView();
});
