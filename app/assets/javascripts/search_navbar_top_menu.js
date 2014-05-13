Blacklight.onLoad(function() {

  // Rotate search navbar menu icon by 90 deg on click
  var $searchNavBar = $('#search-navbar .navbar-header'),
      $iconDropdown = $searchNavBar.find('.dropdown-toggle .icon-menu'),
      cssRotate = 'search-navbar-dropdown-btn-rotate-90';

  $searchNavBar.on('show.bs.dropdown', function() {
    $iconDropdown.addClass(cssRotate)
  });

  $searchNavBar.on('hide.bs.dropdown', function() {
    $iconDropdown.removeClass(cssRotate)
  });

});