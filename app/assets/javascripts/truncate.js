Blacklight.onLoad(function(){
  $("[data-behavior='truncate']").responsiveTruncate({height: 60});
  $("[data-behavior='trunk8']").trunk8();
  $(".gallery-document h3.index_title").trunk8({ lines: 4 });
});

$(window).resize(function() {
  $("[data-behavior='trunk8']").trunk8();
});
