# frozen_string_literal: true

module Searchworks4
  class LinkComponent < ViewComponent::Base
    attr_reader :link

    delegate :link_text, :link_title, :href, :casalini_text, :additional_text, :stanford_only?, to: :link

    def initialize(link:)
      super
      @link = link
    end

    # placeholder for icon, used by articles+ subclass
    def icon = nil

    def stanford_only_icon
      render StanfordOnlyPopoverComponent.new
    end

    def link_attr
      if link_title.present? && stanford_only?
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
