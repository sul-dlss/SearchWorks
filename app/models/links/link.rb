# frozen_string_literal: true

class Links
  class Link
    include ActionView::Helpers::TagHelper

    attr_accessor :href, :file_id, :druid, :type, :sort

    def initialize(options = {})
      @additional_text = options[:additional_text]
      @casalini = options[:casalini]
      @druid = options[:druid]
      @file_id = options[:file_id]
      @finding_aid = options[:finding_aid]
      @fulltext = options[:fulltext]
      @href = options[:href]
      @ill = options[:ill]
      @link_text = options[:link_text]
      @link_title = options[:link_title]
      @managed_purl = options[:managed_purl]
      @sfx = options[:sfx]
      @sort = options[:sort]
      @stanford_only = options[:stanford_only]
      @type = options[:type]
    end

    def ==(other)
      [@href, @fulltext, @stanford_only, @finding_aid, @sfx] == [other.href, other.fulltext?, other.stanford_only?, other.finding_aid?, other.sfx?]
    end

    def html
      @html ||= safe_join([link_html, casalini_text, additional_text_html].compact, ' ')
    end

    def text
      @text ||= safe_join([@link_text, casalini_text, additional_text_html].compact, ' ')
    end

    def fulltext?
      @fulltext
    end

    def stanford_only?
      @stanford_only
    end

    def finding_aid?
      @finding_aid
    end

    def sfx?
      @sfx
    end

    def managed_purl?
      @managed_purl
    end

    def ill?
      @ill
    end

    private

    def additional_text_html
      content_tag(:span, @additional_text, class: 'additional-link-text') if @additional_text
    end

    def casalini_text
      '(source: Casalini)' if @casalini
    end

    def link_class
      'sfx' if @sfx
    end

    def link_html
      content_tag(:a, @link_text, href: @href, title: @link_title, class: link_class)
    end
  end
end
