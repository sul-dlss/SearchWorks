import fetchJsonp from "fetch-jsonp"

(function($) {
  $.fn.libraryH3lp = function() {

    return this.each(function(){
      var $item = $(this),
        $link = $item.find('a').first(),
        $icon = $item.find('span.image-icon'),
        jid = $item.data('jid');
      init();

      function init(){
        checkStatus();
      }

      function checkStatus(){
        var jidSplit = jid.split('@');
        fetchJsonp('https://libraryh3lp.com/presence/jid/' + jidSplit[0] + '/' + jidSplit[1] + '/js',
          {
            jsonpCallback: 'cb'
          })
          .then(() => {
            // The libraryh3lp response sets the jabber_resources at the window level. It doesn't use the callback.
            window['jabber_resources'].forEach((value) => {
              if (value.show === 'available'){
                setAsAvailable()
              } else {
                setAsUnavailable()
              }
            })
          })
      }

      function setAsAvailable(){
        $icon.removeClass('image-icon-message-away');
        $icon.addClass('image-icon-message-available');
        $link.removeClass('disabled');
        $item.on('click', function(e){
          e.preventDefault();
          window.open('//libraryh3lp.com/chat/' + jid + '?skin=16208&sounds=true', 'chat', 'resizable=1,width=420,height=400');
        });
      }

      function setAsUnavailable(){
        $icon.removeClass('image-icon-message-available');
        $icon.addClass('image-icon-message-away');
        $link.addClass('disabled');
        $item.off('click');
        $item.on('click', function(e){
          e.preventDefault();
          return;
        });
      }
    });
  };

})(jQuery);

Blacklight.onLoad(function() {
  $('[data-library-h3lp]').libraryH3lp();
});
