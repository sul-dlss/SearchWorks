# frozen_string_literal: true

module Searchworks4
  class RecordSummaryComponent < ViewComponent::Base
    attr_reader :presenter

    renders_one :thumbnail

    def initialize(presenter:, render_quick_report: false)
      @presenter = presenter
      @render_quick_report = render_quick_report
      super()
    end

    def authors
      return presenter.document.eds_authors if presenter.document.eds?

      sum = []
      %i[creator corporate_author meeting].each do |target|
        sum += presenter.document.linked_author(target).values
      end
      sum.map { |val| [val['link'], val['post_text']].join(' ') }
    end

    def resource_icon
      helpers.render_resource_icon(presenter.formats)
    end

    def default_thumbnail
      Searchworks4::ThumbnailComponent.new(presenter: presenter, counter: nil, classes: %w[document-thumbnail mt-1])
    end

    def render_quick_report?
      @render_quick_report
    end
  end
end
