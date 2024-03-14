# frozen_string_literal: true

module BrowseHelper
  def link_to_callnumber_browse(document, spine, index = 0)
    button_tag(
      spine.base_callnumber,
      class: "collapsed btn btn-secondary",
      id: "callnumber-browse-#{index}",
      "aria-labelledby" => "callnumber-browse-#{index}",
      "aria-expanded" => "true",
      data: { behavior: "embed-browse",
              start: document[:id],
              embed_viewport: "#callnumber-#{index}",
              index_path: browse_index_path(
                start: document[:id],
                call_number: spine.base_callnumber,
                view: :gallery
              ),
              url: browse_nearby_path(
                start: document[:id],
                call_number: spine.base_callnumber,
                view: :gallery
              )
            }
    )
  end
end
