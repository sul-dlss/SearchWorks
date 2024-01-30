# frozen_string_literal: true

module Record
  module Item
    module Mods
      class MetadataComponent < Blacklight::Component
        def initialize(document:)
          @document = document
          super()
        end

        attr_reader :document
      end
    end
  end
end
