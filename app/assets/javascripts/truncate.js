Blacklight.onLoad(function(){
  $("[data-behavior='truncate']").responsiveTruncate({height: 60});
  $("[data-behavior='trunk8']").trunk8();
});

$(window).resize(function() {
  $("[data-behavior='trunk8']").trunk8();
});
