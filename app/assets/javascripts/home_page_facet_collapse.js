(function( $ ){
  $.fn.homePageFacetCollapse = function() {
    var container = this
    $(window).bind("resize", function(){
      addHomePageFacetCollapseBehavior(container, true);
    });
    addHomePageFacetCollapseBehavior(container, false);

    function addHomePageFacetCollapseBehavior( container, resize ){
      container.each(function(){
        this.querySelectorAll(".facet-limit").forEach((facetLimit) => {
          const button = facetLimit.querySelector('[data-toggle="collapse"]')
          const target = document.querySelector(button.dataset.target)

          if(window.innerWidth <= 768) {
            $(target).collapse('hide')
          } else if (resize) {
            $(target).collapse('show')
          }
        });
      });
    };
  };
})( jQuery );
Blacklight.onLoad(function(){
  $("[data-home-page-facet-collapse='true']").homePageFacetCollapse();
});
