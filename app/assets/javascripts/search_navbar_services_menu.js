Blacklight.onLoad(function() {

  // inner dropdown toggles such as Help under the Menu
  // initial/closed state is caret triangle pointed right at 270deg
  // expanded/open state removes the rotation
  $('#search-subnavbar-collapse .navbar-nav .dropdown-toggle').addClass('search-navbar-dropdown-btn-rotate-270').rotateHelper();

});
