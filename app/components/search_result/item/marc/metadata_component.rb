# frozen_string_literal: true

module SearchResult
  module Item
    module Marc
      class MetadataComponent < Blacklight::Component
        TEMPLATE_FIELDS = ['extent', 'db_az_subject', 'summary_data', 'finding_aid', 'index_parent_collections', 'collection_titles'].freeze

        def initialize(document:)
          @document = document
          super()
        end

        attr_reader :document
      end
    end
  end
end
