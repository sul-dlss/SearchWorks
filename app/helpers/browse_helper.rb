module BrowseHelper
  def link_to_callnumber_browse(document, callnumber, index = 0)
    link_to(
      callnumber.callnumber,
      browse_index_path(
        start: document[:id],
        barcode: (callnumber.barcode unless callnumber.barcode == document[:preferred_barcode]),
        view: :gallery
      ), class: "collapsed",
         id: "callnumber-browse-#{index}",
         "aria-labelledby" => "callnumber-browse-#{index}",
         data: { behavior: "embed-browse",
                 start: document[:id],
                 embed_viewport: "#callnumber-#{index}",
                 url: browse_nearby_path(
                   start: document[:id],
                   barcode: (callnumber.barcode unless callnumber.barcode == document[:preferred_barcode]),
                   view: :gallery
                 )
               }
    )
  end
end
