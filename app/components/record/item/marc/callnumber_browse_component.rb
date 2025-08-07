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
            class: "btn #{'active' if index.zero?}",
            id: "callnumber-browse-#{index}",
            type: "button",
            role: "tab",
            aria: {
              controls: "callnumber-#{index}",
              selected: index.zero?
            },
            data: {
              bs_toggle: "tab",
              bs_target: "#callnumber-#{index}",
              start: document.id,
              full_page_url: full_page_path(spine.base_callnumber)
            }
          )
        end

        def filmstrip_path(call_number, **)
          browse_nearby_path(
            start: document.id,
            call_number:,
            view: :gallery,
            **
          )
        end

        def full_page_path(call_number)
          browse_index_path(
            start: document.id,
            call_number:,
            view: :gallery
          )
        end

        def spines
          browseable_spines.first(ITEMS_TO_SHOW)
        end
      end
    end
  end
end
