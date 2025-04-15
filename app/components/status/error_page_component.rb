# frozen_string_literal: true

module Status
  class ErrorPageComponent < ViewComponent::Base
    renders_one :message

    def initialize(code:, header:)
      super
      @code = code
      @header = header
    end

    attr_reader :header, :code
  end
end
