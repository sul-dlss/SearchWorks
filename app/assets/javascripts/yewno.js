
$(window).ready(function() {
  $("#yewno-results").each(function(t) {
    new YewnoRelate({
      containerElementSelector: "#yewno-results",
      urlSearchParam: "q",
      linkDiscover: true,
      definitionCount: 0,
      urlPrefix: "https://stanford.idm.oclc.org/login?url="
    })
  });

  var query = $('#params-q').attr('value');
  $('.yn-figcaption a').addClass('btn-yewno');
  $('.yn-figcaption a').addClass('btn');
  $('.yn-figcaption a').text('Explore "' + query + '" in Yewno Discover');
});
