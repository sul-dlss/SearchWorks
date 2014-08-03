(function($) {
  /*
    jQuery plugin to make elements clickable but w/o a link for accessability purpsoes

      Usage: $(selector).makeElementClickable();
  */

  $.fn.makeElementClickable = function() {

    return this.each(function() {
      var href = $(this).data('no-link-href')
      $(this).css('cursor', 'pointer')
             .on('click.no-link', function(){
               window.location = href;
             });
    });
  }

})(jQuery);

Blacklight.onLoad(function() {
  $('[data-no-link-href]').makeElementClickable();
});
