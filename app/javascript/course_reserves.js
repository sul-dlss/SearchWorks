Blacklight.onLoad(function(){

  // Setup datatable
  var browseCourseReservesTable = $('#course-reserves-browse').DataTable({
    "sDom":  '<"table-top-bar"fil>tp',
    language: {
      info: "_START_ to _END_ of _TOTAL_ reserve lists",
      lengthMenu: "_MENU_ per page",
      search: "Search by course ID, description, or instructor ",
      paginate: {
        previous: "<i class='fa fa-arrow-left'></i> Previous",
        next: "Next <i class='fa fa-arrow-right'></i>"
      }
    },
    "iDisplayLength": 25
  });

  modifyPaginationElements();

  browseCourseReservesTable.on('draw', function(){
    modifyPaginationElements();
  });

  $(document).on('turbolinks:before-cache', function() {
    if (browseCourseReservesTable !== null) {
     browseCourseReservesTable.destroy();
     browseCourseReservesTable = null;
    }
  });

  function modifyPaginationElements(){
    // Change the active anchor element to a span
    $activePaginateBtn = $('#course-reserves-browse_wrapper').find('li.paginate_button.active');
    $activePaginateBtn.find('a').replaceWith(function(){
      return $("<span />").append($(this).contents());
    });

    // Move next button before previous button
    $nextPaginateBtn = $('#course-reserves-browse_wrapper')
      .find('li.paginate_button.next')
      .detach();

    $previousPaginateBtn = $('#course-reserves-browse_wrapper').find('li.paginate_button.previous');
    $previousPaginateBtn.after($nextPaginateBtn);
  }
});
