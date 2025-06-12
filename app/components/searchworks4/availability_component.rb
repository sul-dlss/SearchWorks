# frozen_string_literal: true

module Searchworks4
  class AvailabilityComponent < Blacklight::Component
    def initialize(document:)
      @document = document
      super()
    end

    attr_reader :document
  end
end
