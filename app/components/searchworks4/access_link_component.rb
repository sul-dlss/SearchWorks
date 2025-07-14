# frozen_string_literal: true

module Searchworks4
  class AccessLinkComponent < ViewComponent::Base
    def initialize(link:)
      @link = link
      super
    end

    attr_accessor :link

    delegate :link_title, :casalini_text, :additional_text, :stanford_only?, :sfx?, :href, to: :link

    def call
      safe_join([link_html, casalini_text, additional_text_html].compact, ' ')
    end

    def link_class
      'sfx' if sfx?
    end

    def link_html
      tooltip_attr = if link_title.present? && !stanford_only?
                       {
                         title: link_title,
                         data: { 'bs-placement': 'right', 'bs-toggle': 'tooltip' }
                       }
                     else
                       {}
                     end
      content_tag(:a, link_text, href:, class: link_class, **tooltip_attr)
    end

    def link_text
      link.link_text || link.link_host
    end

    def additional_text_html
      content_tag(:span, additional_text, class: 'additional-link-text') if additional_text
    end
  end
end
