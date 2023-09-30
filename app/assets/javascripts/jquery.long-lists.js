(function(){
  $.fn.longList = function() {

    var uniqId = 0;

    return this.each(function(){
      var $list = $(this),
      $children = $list.children().not('.google-books').filter(function(i){
        return $(this).find('div.google-books').length === 0;
      }),
      type = $list.data("list-type"),
      $more = $('<button class="btn btn-secondary btn-xs" aria-expanded="false">show all<span class="sr-only"> at ' + type + '</span></button>'),
      $less = $('<button class="btn btn-secondary btn-xs" aria-expanded="true">show less<span class="sr-only"> at ' + type + '</span></button>');

      init();

      function init(){
        if ($children.length <= 5) return;

        if (!$list.attr('id')) $list.attr('id', 'long-list-' + uniqId++);
        $more.attr('aria-controls', $list.attr('id'));
        $less.attr('aria-controls', $list.attr('id'));

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
          if ($list.is('tbody')) {
            var tbody = $('<tbody><tr><td></td></tr></tbody>').insertAfter($list);
            tbody.find('td').append($more);
          } else {
            $list.append($more);
          }
        }
        $less.insertAfter($more).hide();
      }
    });
  };

})(jQuery);

Blacklight.onLoad(function() {
  $('[data-long-list]').longList();
});
