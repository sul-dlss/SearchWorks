# frozen_string_literal: true

module EdsLinks
  def eds_links
    @eds_links ||= Links.new(eds_fulltext_links_as_searchworks_links)
  end

  private

  def eds_fulltext_links_as_searchworks_links
    links = eds_fulltext_links.map do |link_field|
      EdsLinks::FulltextLink.new(link_field)
    end

    all_link_categories = links.filter_map(&:category).map(&:to_i)

    links.map { |link| link.to_searchworks_link(all_link_categories) }
  end

  # EDS-centric full text link
  class FulltextLink
    attr_reader :url, :label

    def initialize(link_field)
      link_field = link_field.symbolize_keys
      @url = link_field[:url]
      @original_label = link_field[:label]
      @type = link_field[:type]
      @label = relabel
    end

    def present?
      %w[customlink-fulltext pdf ebook-pdf ebook-epub other].include?(type) && label.present?
    end

    def type
      return 'pdf' if @type == 'pdflink'

      @type
    end

    def blank?
      !present?
    end

    def pdf?
      %w[pdf ebook-pdf ebook-epub].include?(type)
    end

    def ill?
      @original_label.to_s =~ /view request options/i
    end

    def category
      @category ||= map[:category] if map.present? # matches a label exactly

      @category ||= LINK_MAPPING[:open_access_link][:category] unless [/Access URL/i, /Availability/i].any? { |excluded| label&.match?(excluded) } # always exclude these labels
    end

    def to_searchworks_link(all_link_categories = [])
      Links::Link.new(
        link_text: label,
        href:      url,
        fulltext:  present? && show?(all_link_categories),
        ill:       ill?,
        type:,
        stanford_only: pdf? || type == 'other'
      )
    end

    # Link types are prioritized as follows:
    #
    # 1 and 2 are preferred, and can coexist
    # show 3 only if there's no 2 (but can coexist with 1)
    # show the rest only if there is no higher priority link
    #
    # @param [Array<Integer>] `all_categories`
    # @param [Integer] `category`
    def show?(categories)
      case category
      when 1, 2
        true
      when 3
        categories.none?(2)
      when 4, 5, 6, 7
        categories.none? { |i| i < category }
      end
    end

    private

    # Primarily an EDS-label based mapping
    LINK_MAPPING = {
      'HTML full text'.downcase =>           { label: 'View full text', category: 1 },
      'PDF full text'.downcase =>            { label: 'View/download PDF', category: 2 },
      'PDF eBook Full Text'.downcase =>      { label: 'View/download PDF', category: 2 },
      'eBook Full Text'.downcase =>          { label: 'eBook Full Text', category: 3 },
      'EDS Full text'.downcase =>            { label: 'View on content provider\'s site', category: 4 },
      'Full text'.downcase =>                { label: 'View on content provider\'s site', category: 5 },
      :open_access_link =>                   { label: :as_is, category: 6 },
      'View request options'.downcase =>     { label: 'Find full text or request', category: 7 }
    }.freeze
    private_constant :LINK_MAPPING

    def map
      LINK_MAPPING[@original_label.to_s.downcase] || {}
    end

    def relabel
      return map[:label] if map[:label].present? && map[:label] != :as_is

      @original_label
    end
  end
end
