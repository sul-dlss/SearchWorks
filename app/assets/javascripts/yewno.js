
$(window).ready(function() {
  $("#yewno-results").each(function(t) {
    new YewnoDiscoverWidget({
      containerElementSelector: "#yewno-results",
      urlSearchParam: "q"
    })
  });
}); 
