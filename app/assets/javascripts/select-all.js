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
          var first = false;
          var firstCheckboxIsDone = new $.Deferred();
          bookmarkSelectors.each(function(i, checkbox) {
            if (!first){
              var $checkbox = $(checkbox);
              if ($checkbox.is(':checked') !== state) {
                var span = $checkbox.next('span');              
                first = true;
                $checkbox.prop('checked', !state).click();
                span.on('DOMSubtreeModified', function(){
                  firstCheckboxIsDone.resolve();
                });
              }
            }
          });
          $.when(firstCheckboxIsDone).done(function(){
            bookmarkSelectors.each(function(i, checkbox) {
              var $checkbox = $(checkbox);
              if ($checkbox.is(':checked') !== state) {
                $checkbox.prop('checked', !state).click();
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
