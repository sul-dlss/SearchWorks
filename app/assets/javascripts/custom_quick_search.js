function remove_timedout_spinners(){
  if (!document.querySelector('.trying_again')) return;

  document.querySelector('.trying_again').remove();
}

function add_found_item_types(endpoint) {
  $('.result-types li.' + endpoint + " .no-results-label")
    .replaceWith('<a href="#' + endpoint + '" data-quicksearch-ga-action="' +
      endpoint + '">' + I18n["en"][endpoint + "_search"]["display_name"] + ' </a>');
}

var xhr_searches = function(){
  // We want to remove the spinners once all of the ajax requests are done. To do this we create an array of all of the ajax
  // requests, which are promises. We can then apply this array so that all the promises are wrapped up together. When
  // they're all done then the 'then' function runs removing the spinners.
  $.when.apply(this,
    $('.search-error').map(function(index){
      var that = $(this);
      var parent = that.parent('.module-contents');
      var url = that.data('quicksearch-xhr-url');

      parent.append('<div class="trying_again"><i class="fas fa-sync-alt fa-spin" aria-hidden="true"></i> Just a few more seconds </div>');

      return $.ajax({
        url: url,
        timeout: 15000,
        success: function(response){
          var response_object = jQuery.parseJSON(response);
          var endpoint = Object.keys(response_object)[0];

          if (response_object[endpoint].indexOf("search-error-message") <= -1) {
            add_found_item_types(endpoint);
          }
          if (response_object.spelling_suggestion != ' ') {
              $('#spelling-suggestion').append(response_object.spelling_suggestion).removeClass('hidden');
          }
          if (response_object.related_topics != ' ') {
              $('#related-topics').append(response_object.related_topics).removeClass('hidden');
          }

          parent.replaceWith(response_object[endpoint]);
        },
        error: function(){
          parent.find('.trying_again').remove();
          parent.find('.search-error-rescue').show();
        }
      });
    })
  ).then(
    // No matter what the result (success, failure) the spinners ought to be removed.
    remove_timedout_spinners
    );
}

$(document).ready(function() {
  xhr_searches();
});

//  add a >> to the focused element
$(document).ready(function() {

    // Fade out best bet highlight after 3 seconds
    if (window.innerWidth > 640) {
        $('.highlight').delay( 6000 ).fadeOut( 500 );
    } else {
        $('.highlight').remove();
    }
});

//  This handles the highlighting of modules when a result types quide link is clicked
$(document).on('click', '.result-types a', function () {

    // Grab the hash value
    var hash = this.hash.substr(1);

    // Remove any active highlight
    $('.result-types-highlight').remove();

    // Add the highlight
    $('#' + hash + ' h2').prepend('<span class="result-types-highlight"><i class="fa fa-angle-double-right highlight" aria-hidden="true"></i>&nbsp;</span>');

    // Fade it away and then remove it.
    $('#' + hash + ' .highlight').delay( 3000 ).animate({backgroundColor: 'transparent'}, 500 );
    setTimeout(function() {
        $('#' + hash + ' .result-types-highlight').remove();
    }, 3550);
});
