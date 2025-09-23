# frozen_string_literal: true

module Searchworks4
  class DocumentFlagComponent < ViewComponent::Base
    attr_reader :document

    def initialize(document:)
      super()
      @document = document
    end

    def render?
      document.is_a_collection? || document.has_finding_aid?
    end

    def badge_classes
      if document.stanford_archives_finding_aid?
        'text-palo-alto-dark'
      else
        'text-secondary'
      end
    end
  end
end
