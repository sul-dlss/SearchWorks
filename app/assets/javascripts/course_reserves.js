Blacklight.onLoad(function(){
  $('#course-reserves-browse').dataTable({
    "sDom":  '<"container-fluid"<"row"<"col-md-6"f><"col-md-6"<"row"<"col-md-6"i><"col-md-6"l>>>><t><"row"<"col-md-12"p>>>',
    "sPaginationType": "bootstrap",
    "oLanguage": {
      "sSearch": "Search by course ID, description, or instructor: "
    }
  });
});
