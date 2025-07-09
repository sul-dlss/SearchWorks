# frozen_string_literal: true

module Databases
  class SearchBarComponent < Blacklight::SearchBarComponent
    def initialize(**kwargs)
      super

      @q ||= @params.dig(:f, 'db_az_subject', 0)
    end

    def search_button
      render SearchButtonComponent.new(id: "#{@prefix}search", text: 'Search')
    end
  end
end
