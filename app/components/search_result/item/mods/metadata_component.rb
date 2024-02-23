# frozen_string_literal: true

module SearchResult
  module Item
    module Mods
      class MetadataComponent < Blacklight::Component
        TEMPLATE_FIELDS = ['extent', 'summary_data', 'index_parent_sets', 'index_parent_collections'].freeze

        def initialize(document:)
          @document = document
          super()
        end

        attr_reader :document
      end
    end
  end
end
