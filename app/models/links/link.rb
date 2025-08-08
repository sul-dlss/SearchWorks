# frozen_string_literal: true

class Links
  class Link
    include ActionView::Helpers::TagHelper

    attr_accessor :href, :file_id, :druid, :type, :sort, :link_title

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
      @sort = options[:sort]
      @stanford_only = options[:stanford_only]
      @type = options[:type]
    end

    def text
      @text ||= safe_join([link_text, casalini_text, additional_text_html].compact, ' ')
    end

    def part_label(index:)
      @link_text || ("part #{index}" if index) || "part"
    end

    def link_text
      @link_text || link_host
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

    def managed_purl?
      @managed_purl
    end

    def ill?
      @ill
    end

    def additional_text_html
      content_tag(:span, additional_text, class: 'additional-link-text') if @additional_text
    end

    attr_reader :additional_text

    def casalini_text
      '(source: Casalini)' if @casalini
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

    def as_json(*)
      {
        type: @type,
        href: @href,
        stanford_only: @stanford_only,
        link_text: link_text,
        source: casalini_text,
        additional_text: @additional_text
      }
    end
  end
end
