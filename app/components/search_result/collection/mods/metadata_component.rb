# frozen_string_literal: true

module SearchResult
  module Collection
    module Mods
      class MetadataComponent < Blacklight::Component
        TEMPLATE_FIELDS = ['extent', 'summary_data'].freeze

        def initialize(document:)
          @document = document
          super()
        end

        attr_reader :document
      end
    end
  end
end
