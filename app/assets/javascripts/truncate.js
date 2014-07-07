Blacklight.onLoad(function(){
  $("[data-behavior='truncate']").responsiveTruncate({height: 60});
  $("[data-behavior='trunk8']").trunk8();
  $(".gallery-document .caption h3").trunk8({ lines: 4 });
});

$(window).resize(function() {
  $("[data-behavior='trunk8']").trunk8();
});
