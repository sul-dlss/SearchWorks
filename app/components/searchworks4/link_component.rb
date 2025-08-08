# frozen_string_literal: true

module Searchworks4
  class LinkComponent < ViewComponent::Base
    attr_reader :link

    def initialize(link:)
      super
      @link = link
    end

    def stanford_only_icon
      render StanfordOnlyPopoverComponent.new
    end

    def tooltip_attr
      if link.link_title.present? && !link.stanford_only?
        {
          title: link.link_title,
          data: { 'bs-placement': 'right', 'bs-toggle': 'tooltip' }
        }
      else
        {}
      end
    end
  end
end
