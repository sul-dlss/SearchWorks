module BrowseHelper
  def link_to_callnumber_browse(document, callnumber, index = 0)
    button_tag(
      callnumber.callnumber,
      class: "collapsed",
      id: "callnumber-browse-#{index}",
      "aria-labelledby" => "callnumber-browse-#{index}",
      "aria-expanded" => "true",
      data: { behavior: "embed-browse",
              start: document[:id],
              embed_viewport: "#callnumber-#{index}",
              index_path: browse_index_path(
                start: document[:id],
                barcode: (callnumber.barcode unless callnumber.barcode == document[:preferred_barcode]),
                view: :gallery
              ),
              url: browse_nearby_path(
                start: document[:id],
                barcode: (callnumber.barcode unless callnumber.barcode == document[:preferred_barcode]),
                view: :gallery
              )
            }
    )
  end
end
