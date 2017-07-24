Blacklight.onLoad(function(){

  $('#toggleFulltext').on('show.bs.collapse', function(){
    $('#fulltextToggleBar').html('<h2>Hide full text</h2>')
  });

  $('#toggleFulltext').on('hide.bs.collapse', function(){
    $('#fulltextToggleBar').html('<h2>Show full text</h2>')
  });
})
