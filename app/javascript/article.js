Blacklight.onLoad(function(){
  $('#toggleFulltext').on('show.bs.collapse', function(){
    $('#fulltextToggleBar').html('<h2>Hide full text <i class="fa fa-chevron-down"></i></h2>')
  });

  $('#toggleFulltext').on('hide.bs.collapse', function(){
    $('#fulltextToggleBar').html('<h2>Show full text <i class="fa fa-chevron-right"></i></h2>')
  });

  // toggles close icon from plus to X and vice versa
  $('#research-starter-body').on('hide.bs.collapse', function () {
    $('#research-starter-close-icon').removeClass('fa-times-circle').addClass('fa-plus-circle');
  });

  $('#research-starter-body').on('show.bs.collapse', function () {
    $('#research-starter-close-icon').removeClass('fa-plus-circle').addClass('fa-times-circle');
  });
})
