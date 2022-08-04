Blacklight.onLoad(function() {

  // top level Menu in navbar-header
  $('.navbar-toggle').rotateHelper();

  // inner dropdown toggles such as Help under the Menu
  // initial state is caret triangle pointed right at 270deg
  $('#search-subnavbar-collapse .navbar-nav .dropdown-toggle').addClass('search-navbar-dropdown-btn-rotate-270').rotateHelper();

});
