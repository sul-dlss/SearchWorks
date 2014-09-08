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
          selectorSelectBookmarks = 'input.toggle_bookmark',
          selectionType = {
            true: 'select',
            false: 'unselect'
          };

      setInitialAction();
      init();

      function init() {
        var self = this;
        $element.on('click', function() {
          self.state = $selectAll.is(':visible');
          var data = {
            "bookmarks": [],
            "selectAll": state
          };
          $(selectorSelectBookmarks).each(function(i, checkbox) {
            var $checkbox = $(checkbox);
            if ($checkbox.is(':checked') !== self.state) {
              data.bookmarks.push($checkbox.attr('id').replace('toggle_bookmark_', ''));
            }
            
          });
          sendSelections(data);
          toggleActions();
        });
      }
      
      function sendSelections(data){
        $.ajax({
          type: 'POST',
          url: '/select_all/' + selectionType[data.selectAll],
          data: data,
          success: function(response){
            if (response.bookmarks) {
             $('[data-role=bookmark-counter]').text(response.bookmarks.count);
            }
            console.log(response.status);
            if (response.status){
              updateCheckBoxes();
            }
          }
        });
      }
      
      function updateCheckBoxes(){
        $(selectorSelectBookmarks).each(function(i, checkbox) {
          var $checkbox = $(checkbox);
          
          if ($checkbox.is(':checked') !== self.state) {
            var form = $checkbox.closest('form');
            var span = form.find('span');
            if (self.state){
              form.find("input[name=_method]").val("delete");
              span.text(form.attr('data-present'));
            } else {
              form.find("input[name=_method]").val("put");
              span.text(form.attr('data-absent'));
            }
            $checkbox.prop("checked", self.state);
          }
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
