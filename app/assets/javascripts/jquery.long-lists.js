(function(){
  $.fn.longList = function() {

    return this.each(function(){
      var $list = $(this),
      $children = $list.children().not('.google-books').filter(function(i){
        return $(this).find('div.google-books').length === 0;
      }),
      type = $list.data("list-type"),
      $more = $('<button class="btn btn-default btn-xs">show all<span class="sr-only"> at ' + type + '</span></button>'),
      $less = $('<button class="btn btn-default btn-xs">show less<span class="sr-only"> at ' + type + '</span></button>');

      init();

      function init(){
        if ($children.length > 5){
          $children.hide().slice(0,5).show();
          $more.on('click', function(e){
            e.preventDefault();
            $children.fadeIn();
            $more.hide();
            $less.fadeIn();
          });
          $less.on('click', function(e){
            e.preventDefault();
            $children.hide().slice(0,5).show();
            $less.hide();
            $more.fadeIn();
          });
          $googleBooks = $list.find('li>div.google-books, .google-books');
          if ($googleBooks.length > 0){
            $googleBooks.before($more);
          }else{
            $list.append($more);
          }
          $less.insertAfter($more).hide();
        }
      }
    });
  };

})(jQuery);

Blacklight.onLoad(function() {
  $('[data-long-list]').longList();
});
