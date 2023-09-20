(function( $ ){
  $.fn.homePageFacetCollapse = function() {
    var container = this
    $(window).bind("resize", function(){
      addHomePageFacetCollapseBehavior(container, true);
    });
    addHomePageFacetCollapseBehavior(container, false);

    function addHomePageFacetCollapseBehavior( container, resize ){
      container.each(function(){
        $(".facet_limit", $(this)).each(function(){
          var header = $('.card-header', $(this))
          var target = $(header.data('target'));

          if($(window).width() <= '768') {
            header.addClass('collapsed');
            target.addClass('collapse');
            target.removeClass('in');
            header.attr('aria-expanded', 'false');
          }else if (resize && !target.data('toggle-default')){
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
