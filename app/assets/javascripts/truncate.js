Blacklight.onLoad(function(){
  $("[data-behavior='article-metadata-truncate']").responsiveTruncate(
    { height: 40, more: 'more...', less: 'less...' }
  );
  $("[data-behavior='truncate']").responsiveTruncate({height: 60});
  $("[data-behavior='trunk8']").trunk8({
    tooltip: false
  });
  $(".gallery-document h3.index_title a").trunk8({ lines: 4 });
});
