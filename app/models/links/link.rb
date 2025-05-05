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
      @text ||= safe_join([@link_text || link_host, casalini_text, additional_text_html].compact, ' ')
    end

    def part_label(index:)
      @link_text || ("part #{index}" if index) || "part"
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

    def link_host
      return if @href.blank?

      uri = URI.parse(Addressable::URI.encode(@href.strip))
      host = uri.host
      if host =~ Links::PROXY_REGEX && uri.query
        query = CGI.parse(uri.query)
        host = URI.parse(query['url'].first).host if query['url'].present?
      end
      host || @href
    rescue URI::InvalidURIError, Addressable::URI::InvalidURIError
      @href
    end

    def link_html
      tooltip_attr = if @link_title.present? && !stanford_only?
                       {
                         title: @link_title,
                         data: { 'bs-placement': 'right', 'bs-toggle': 'tooltip' }
                       }
                     else
                       {}
                     end
      content_tag(:a, @link_text || link_host, href: @href, class: link_class, **tooltip_attr)
    end
  end
end
