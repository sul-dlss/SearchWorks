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
          const state = $selectAll.is(':visible');
          bookmarkSelectors = $(selectorSelectBookmarks);
          let first = true;
          const checkFirstBox = new Promise((resolve) => {
            const observer = new MutationObserver(function(mutationList) {
              for (const mutation of mutationList) {

                mutation.addedNodes.forEach(function(node) {
                  console.log("Mutation", node)
                  if (node.data != 'Saving...') {
                    console.log("starting the rest", node.data)

                    resolve()
                  }
                })
              }
            })

            bookmarkSelectors.each(function(i, checkbox) {
              if (first) {
                if (checkbox.checked !== state) {
                  console.log("first box checked")
                  first = false;
                  const span = checkbox.closest('form').querySelector('[data-checkboxsubmit-target="span"]')
                  observer.observe(span, { childList: true, subtree: true });
                  const event = new MouseEvent("click", {
                    view: window,
                    bubbles: true,
                    cancelable: true,
                  })
                  checkbox.dispatchEvent(event)
                }
              }
            })
          })

          checkFirstBox.then(() => {
            // Check the rest of the boxes
            bookmarkSelectors.each(async function(i, checkbox) {
              if (checkbox.checked !== state) {
                console.log("subsequent box checked")

                const event = new MouseEvent("click", {
                  view: window,
                  bubbles: true,
                  cancelable: true,
                })
                checkbox.dispatchEvent(event)
                if (i > 20) {
                  // Avoid trigging DOS protection in the loadbalancer.
                  await new Promise(r => setTimeout(r, 500))
                }
              }
            })
          })

          toggleActions()
        })
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
