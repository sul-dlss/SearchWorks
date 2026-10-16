# frozen_string_literal: true

module Record
  class MarcContentAdviceComponent < ViewComponent::Base
    def initialize(document:)
      super()
      @document = document
      @content_advice = document.fetch(:summary_struct, []).select { |elem| elem[:label] == 'Content advice' }
    end

    attr_reader :content_advice

    def render?
      content_advice.present?
    end

    def content_advice_values
      content_advice.flat_map do |h|
        h[:fields].presence&.map { |field| field[:field].presence } || h[:unmatched_vernacular]
      end.compact
    end

    def call
      content_tag(:div, class: 'py-3 px-5 mb-3 alert theme-warning border-0 fg-body content-advice') do
        tag.strong('Content advice: ') +
          safe_join(content_advice_values, tag.br)
      end
    end
  end
end
