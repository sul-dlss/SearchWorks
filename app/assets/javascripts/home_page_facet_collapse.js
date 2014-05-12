(function( $ ){
  $.fn.homePageFacetCollapse = function( options ) {
    var container = this
    $(window).bind("resize", function(){
      addHomePageFacetCollapseBehavior(container);
    });
    addHomePageFacetCollapseBehavior(container);
    function addHomePageFacetCollapseBehavior( container ){
      container.each(function(){
        $(".home-facet", $(this)).each(function(){
          var header = $('.panel-heading', $(this))
          var target = $(header.data('target'));
          if($(window).width() <= '768') {
            header.addClass('collapsed');
            target.removeClass('in');
          }else{
            header.removeClass('collapsed');
            target.addClass('in');
            target.css('height', 'auto');
          }
        });
      });
    };
  };
})( jQuery );
Blacklight.onLoad(function(){
  $("[data-home-page-facet-collapse='true']").homePageFacetCollapse();
});
