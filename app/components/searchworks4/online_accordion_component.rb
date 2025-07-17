# frozen_string_literal: true

module Searchworks4
  class OnlineAccordionComponent < ViewComponent::Base
    attr_reader :document

    def initialize(document:, toggled_library:)
      @document = document
      @toggled_library = toggled_library
      super
    end

    def render?
      links.present?
    end

    def links
      document.preferred_online_links
    end

    def toggled_library?
      return true unless @toggled_library

      @toggled_library == 'online'
    end
  end
end
