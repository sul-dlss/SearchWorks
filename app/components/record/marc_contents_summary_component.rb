# frozen_string_literal: true

module Record
  class MarcContentsSummaryComponent < ViewComponent::Base
    def initialize(document:)
      super
      @document = document
    end

    attr_reader :document

    delegate :render_if_present, :render_struct_field_data, to: :helpers

    def summaries
      document.fetch(:summary_struct, []).reject { |elem| elem[:label] == 'Content advice' }
    end
  end
end
