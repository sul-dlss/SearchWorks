$(document).on('page:before-change', function(){
  $('body').css('cursor', 'wait');
});

$(document).on('page:change', function(){
  $('body').css('cursor', 'auto');
});
