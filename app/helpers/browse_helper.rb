module BrowseHelper
  def link_to_callnumber_browse(document, item, index = 0)
    button_tag(
      item.callnumber,
      class: "collapsed btn btn-secondary",
      id: "callnumber-browse-#{index}",
      "aria-labelledby" => "callnumber-browse-#{index}",
      "aria-expanded" => "true",
      data: { behavior: "embed-browse",
              start: document[:id],
              embed_viewport: "#callnumber-#{index}",
              index_path: browse_index_path(
                start: document[:id],
                barcode: (item.barcode unless item.barcode == document[:preferred_barcode]),
                view: :gallery
              ),
              url: browse_nearby_path(
                start: document[:id],
                barcode: (item.barcode unless item.barcode == document[:preferred_barcode]),
                view: :gallery
              )
            }
    )
  end
end
