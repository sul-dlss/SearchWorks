# frozen_string_literal: true

module Articles
  class IndexBriefComponent < ViewComponent::Base
    with_collection_parameter :document

    def initialize(document:, document_counter:)
      super
      @document = document
      @document_counter = document_counter
    end

    def counter
      document_counter_with_offset(document_counter)
    end

    def doc_formats
      document_presenter(document).formats
    end

    attr_reader :document, :document_counter

    delegate :document_presenter, :render_resource_icon, :document_counter_with_offset,
             :link_to_document, :get_main_title_date, :render_index_doc_actions, to: :helpers
  end
end
