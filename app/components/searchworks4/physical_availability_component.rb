# frozen_string_literal: true

module Searchworks4
  class PhysicalAvailabilityComponent < Blacklight::Component
    attr_reader :document, :header_classes

    delegate :link_to_document, to: :helpers

    def initialize(document:, classes: %w[availability-component border rounded p-2 fs-15], header_classes: %w[gap-4 row-gap-2 align-items-center flex-wrap])
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
      document.holdings.items.one? && single_location?
    end

    def truncated_display?
      document.holdings.items.count > 10
    end

    def single_location?
      document.holdings.libraries.one? && document.holdings.libraries.first.locations.one?
    end

    # Group SAL* libraries together into a single category
    def library_groups
      @library_groups ||= begin
        grouped = document.holdings.libraries.group_by do |library|
          if library.code.start_with?('SAL')
            'OFF_CAMPUS'
          else
            library.code
          end
        end

        grouped.except('OFF_CAMPUS').values.map { |libraries| LibraryGroup.new(libraries) } + [(LibraryGroup.new(grouped['OFF_CAMPUS']) if grouped['OFF_CAMPUS'])].compact
      end
    end

    class LibraryGroup
      attr_reader :libraries

      def initialize(libraries)
        @libraries = libraries
      end

      def name
        libraries.first.name
      end
    end

    class LocationComponent < ViewComponent::Base
      attr_reader :location, :document

      def initialize(location:, document:, classes: ['text-nowrap'], suppress_off_campus: true)
        @location = location
        @document = document
        @classes = classes
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
          analytics = { action: "click->analytics#trackLink", controller: "analytics", analytics_category_value: "item_location" }
          link_to stackmap_path(id: document.id, location: location.code), data: { blacklight_modal: 'trigger', **analytics }, class: @classes + ['location-name'] do
            tag.i(class: "bi bi-geo-alt-fill me-1") + location.name
          end
        else
          tag.span location.name, class: @classes + ['location-name']
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
