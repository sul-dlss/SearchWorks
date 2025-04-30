(function($) {

  /*
    jQuery plugin for selecting/unselecting bookmarks

      Usage: $(selector).selectUnSelectAll();
  */


  $.fn.selectUnSelectAll = function() {

    return this.each(function() {
      var $element = $(this),
          $selectAll = $element.find('span.select-all'),
          $unSelectAll = $element.find('span.unselect-all'),
          selectorSelectBookmarks = 'input.toggle-bookmark';

      setInitialAction();
      init();

      function init() {
        $element.on('click', toggleAll)
      }

      function toggleAll() {
        const state = $selectAll.is(':visible')
        document.querySelectorAll(selectorSelectBookmarks).forEach(async (checkbox, index) => {
          if (checkbox.checked !== state) {
            const event = new MouseEvent("click", {
              view: window,
              bubbles: true,
              cancelable: true,
            })
            checkbox.dispatchEvent(event)
          }
          if (index > 20) {
            // Avoid trigging DOS protection in the loadbalancer.
            await new Promise(r => setTimeout(r, 500))
          }
        })

        toggleActions()
      }

      function setInitialAction() {
        if ($(selectorSelectBookmarks + ':checked').length !== 0) {
          toggleActions();
        }
      }

      function toggleActions() {
        $selectAll.toggle();
        $unSelectAll.toggle();
      }

    });

  };

})(jQuery);


Blacklight.onLoad(function() {
    $('#select_all-dropdown').selectUnSelectAll();
});
