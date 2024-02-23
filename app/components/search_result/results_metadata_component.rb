# frozen_string_literal: true

module SearchResult
  class ResultsMetadataComponent < ViewComponent::Base
    def initialize(document:, template_fields:)
      @document = document
      @template_fields = template_fields
      super()
    end

    def present_fields
      @present_fields ||= @template_fields.map.to_h do |field|
        if field == 'summary_data'
          [field, summary_data]
        else
          [field, document.public_send(field)]
        end
      end.compact_blank
    end

    attr_reader :document

    def summary_data
      summary_data = SummaryDataComponent.new(document:)
      summary_data if summary_data.render?
    end

    def render?
      present_fields.any?
    end
  end
end
