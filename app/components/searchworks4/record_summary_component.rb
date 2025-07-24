# frozen_string_literal: true

module Searchworks4
  class RecordSummaryComponent < ViewComponent::Base
    attr_reader :presenter

    def initialize(presenter:)
      @presenter = presenter
      super
    end

    def authors
      return presenter.document.eds_authors&.uniq if presenter.document.eds?

      sum = []
      %i[creator corporate_author meeting].each do |target|
        sum += presenter.document.linked_author(target).values
      end
      sum.map { |val| [val['link'], val['post_text']].join(' ') }
    end

    def resource_icon
      helpers.render_resource_icon(presenter.formats)
    end
  end
end
