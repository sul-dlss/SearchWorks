# frozen_string_literal: true

module SearchResult
  module Collection
    module Marc
      class MetadataComponent < Blacklight::Component
        TEMPLATE_FIELDS = ['extent', 'summary_data', 'finding_aid'].freeze

        def initialize(document:)
          @document = document

          super()
        end

        attr_reader :document
      end
    end
  end
end
