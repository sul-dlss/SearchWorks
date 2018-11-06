// Overridden from upstream to add custom error callback
//= require blacklight/core
//= require blacklight/checkbox_submit
(function($) {
//change form submit toggle to checkbox
    Blacklight.do_bookmark_toggle_behavior = function() {
      $(Blacklight.do_bookmark_toggle_behavior.selector).bl_checkbox_submit({
         //css_class is added to elements added, plus used for id base
         css_class: "toggle_bookmark",
         error: function() {
           alert("'Select' has encountered a problem it can't recover from. Try again later.");
         },
         success: function(checked, response) {
           if (response.bookmarks) {
             $('[data-role=bookmark-counter]').text(response.bookmarks.count);
           }
         }
      });
    };
    Blacklight.do_bookmark_toggle_behavior.selector = "form.bookmark_toggle"; 

Blacklight.onLoad(function() {
  Blacklight.do_bookmark_toggle_behavior();  
});
  

})(jQuery);
