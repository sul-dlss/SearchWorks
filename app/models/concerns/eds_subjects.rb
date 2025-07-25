# frozen_string_literal: true

module EdsSubjects
  # EDS-centric subject with linking capability
  class Subject
    attr_reader :terms
    delegate :present?, to: :terms

    class Term < Struct.new(:field_code, :search_term, :label)
      delegate :to_s, to: :label

      def search_field
        case field_code
        when 'SH'
          'subject_heading'
        when 'DE'
          'descriptor'
        when 'SU'
          'subject'
        when 'KW'
          'keyword'
        else
          'subject'
        end
      end

      def to_html
        # TODO: we don't have a view context for `link_to`
        "<a href=\"#{Rails.application.routes.url_helpers.articles_path(q: search_term, search_field:)}\">#{CGI.escapeHTML(label)}</a>"
      end
    end

    def initialize(terms)
      @terms = Array(terms)
    end

    def to_s
      terms.map(&:to_s).join(' -- ')
    end

    def to_html
      terms.map(&:to_html).join(' -- ')
    end

    # @return [Array<Subject>]
    def self.from(string_or_array)
      return [] if string_or_array.blank?

      xml = Array.wrap(string_or_array).map { |s| convert_simple_string_to_xml(s) }.join('<br/>')
      from_xml(xml)
    end

    def self.convert_simple_string_to_xml(subject)
      return subject if /<searchLink/i.match?(subject) # already has markup

      "<searchLink fieldCode=\"DE\" term=\"#{subject}\">#{subject}</searchLink>"
    end

    def self.from_xml(xml)
      xml.split(/<br[\s\/]*>/).collect do |xml_fragment|
        doc = Nokogiri::XML("<links>#{xml_fragment}</links>")
        from_search_link_nodes(doc.xpath('//searchLink').to_a)
      end.flatten
    end

    # Each subject may have many terms, each with their own <searchLink>
    # @return [Array<Subject>]
    def self.from_search_link_nodes(search_links)
      terms = search_links.collect do |node|
        term = Term.new
        term.label = node.text
        term.field_code = node['fieldcode'] || node['fieldCode']
        term.search_term = CGI.unescape(node['term'].to_s)
        if /\s+/.match?(term.search_term)
          term.search_term = "\"#{term.search_term}\"" unless /^"/.match?(term.search_term) # quote if not quoted
        else
          term.search_term.delete!('"') # no quotes for single words
        end
        term
      end
      Subject.new(terms)
    end
  end
end
