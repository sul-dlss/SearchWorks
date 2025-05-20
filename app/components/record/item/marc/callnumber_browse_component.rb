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
            class: "btn btn-secondary #{'active' if index.zero?}",
            id: "callnumber-browse-#{index}",
            type: "button",
            role: "tab",
            aria: {
              controls: "callnumber-#{index}",
              selected: index.zero?
            },
            data: { behavior: "embed-browse",
                    bs_toggle: "tab",
                    bs_target: "#callnumber-#{index}",
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
