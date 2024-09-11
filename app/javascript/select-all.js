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
        $element.on('click', function() {
          var state = $selectAll.is(':visible');
          bookmarkSelectors = $(selectorSelectBookmarks);
          var first = true;
          var firstCheckboxIsDone = new $.Deferred();
          var observer = new MutationObserver(function(mutationList) {
            for (const mutation of mutationList) {
              mutation.addedNodes.forEach(function(node) {
                if (node.text != 'Saving...') {
                  firstCheckboxIsDone.resolve();
                }
              });
            }
          });

          bookmarkSelectors.each(function(i, checkbox) {
            if (first) {
              var $checkbox = $(checkbox);
              if ($checkbox.is(':checked') !== state) {
                first = false;
                var span = $checkbox.next('span');
                observer.observe(span[0], { childList: true, subtree: true });
                $checkbox.prop('checked', !state).click();
              }
            }
          });

          $.when(firstCheckboxIsDone).done(function(){
            bookmarkSelectors.each(async function(i, checkbox) {
              var $checkbox = $(checkbox);
              if ($checkbox.is(':checked') !== state) {
                $checkbox.prop('checked', !state).click();
                if (i > 20) {
                  // Avoid trigging DOS protection in the loadbalancer.
                  await new Promise(r => setTimeout(r, 500));
                }
              }
            });
          });
          
          toggleActions();
        });
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
