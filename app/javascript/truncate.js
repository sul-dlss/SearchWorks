Blacklight.onLoad(function(){
  $("[data-behavior='metadata-truncate']").responsiveTruncate(
    { lines: 2, more: 'more...', less: 'less...' }
  );
  $("[data-behavior='truncate-results-metadata-links']").responsiveTruncate({lines: 2, more: 'more...', less: 'less...'});
  $("[data-behavior='truncate']").responsiveTruncate({height: 60});
});
