(function(){
  $.fn.purlEmbed = function() {

    return this.each(function(){
      var $embedViewer = $(this);
      var $embedURL = $embedViewer.data('embed-url');
      init();

      function init(){
        $.getJSON($embedURL, function(data){
          if (data === null){
            return;
          }
          $embedViewer.html(data.html);
        });
      }
    });
  };

})(jQuery);

Blacklight.onLoad(function() {
  $('[data-behavior="purl-embed"]').purlEmbed();
});
