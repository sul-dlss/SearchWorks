# frozen_string_literal: true

module Searchworks4
  class PhysicalAvailabilityComponent < Blacklight::Component
    attr_reader :document, :header_classes

    delegate :link_to_document, to: :helpers

    def initialize(document:, classes: %w[availability-component border rounded p-2 fs-15], header_classes: %w[gap-4 row-gap-3 align-items-center flex-wrap flex-sm-nowrap])
      @document = document
      @classes = classes
      @header_classes = header_classes

      super()
    end

    def render?
      document.holdings.present?
    end

    def container_tag(tag_name = 'div', classes: nil, **, &)
      tag.public_send(tag_name, data: { controller: 'availability' }, class: @classes + (tag_name == 'details' ? [] : @header_classes) + Array(classes), **, &)
    end

    def single_item?
      document.holdings.items.one? && document.holdings.libraries.one?
    end

    def truncated_display?
      document.holdings.items.count > 20
    end

    def single_location?
      document.holdings.libraries.one? && document.holdings.libraries.first.locations.one?
    end

    class LocationComponent < ViewComponent::Base
      attr_reader :location, :document

      def initialize(location:, document:, suppress_off_campus: true)
        @location = location
        @document = document
        @suppress_off_campus = suppress_off_campus
        super
      end

      def render?
        !(@suppress_off_campus && location.code.include?('SAL3-'))
      end

      def stackmappable?
        location.stackmapable? && location.items.first&.callnumber.present?
      end

      def call
        if stackmappable?
          link_to helpers.stackmap_link(document, location), data: { blacklight_modal: 'trigger' }, class: 'stackmap-find-it location-name text-nowrap' do
            tag.i(class: "bi bi-geo-alt-fill me-1") + location.name
          end
        else
          tag.span location.name, class: 'location-name'
        end
      end
    end

    class ItemCountComponent < ViewComponent::Base
      def initialize(count)
        @count = count
        super
      end

      def call
        tag.span pluralize(@count, 'item'), class: 'bg-light rounded-pill small px-2 lh-sm text-nowrap'
      end
    end
  end
end
