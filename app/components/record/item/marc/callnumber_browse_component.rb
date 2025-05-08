# frozen_string_literal: true

module Record
  module Item
    module Marc
      class CallnumberBrowseComponent < ViewComponent::Base
        ITEMS_TO_SHOW = 3

        def initialize(document:)
          @document = document
          super
        end

        attr_reader :document

        delegate :browseable_spines, to: :document

        def render?
          Settings.browse_nearby.enabled && browseable_spines.present?
        end

        def link_to_callnumber_browse(spine, index = 0)
          button_tag(
            spine.base_callnumber,
            class: "collapsed btn btn-secondary",
            id: "callnumber-browse-#{index}",
            "aria-controls" => "callnumber-browse-#{index}",
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
                    ) }
          )
        end

        def spines
          browseable_spines.first(ITEMS_TO_SHOW)
        end
      end
    end
  end
end
