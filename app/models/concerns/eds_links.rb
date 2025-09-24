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

    categories = links.filter_map(&:category).map(&:to_i)

    mapped_links = links.map { |link| link.to_searchworks_link(categories) }

    process_view_content_links(mapped_links)
  end

  def process_view_content_links(mapped_links)
    # Are there multiple fulltext links with different link texts
    fulltext_links = mapped_links.select(&:fulltext?)
    fulltext_text = fulltext_links.filter_map(&:link_text).uniq

    # If there are multiple fulltext links, and one is 'View on content provider's site',
    # we do NOT want to use the 'View on content provider's site' link.
    # Settung the 'fulltext' prope
    if fulltext_text.size > 1 && fulltext_text.include?('View on content provider\'s site')
      mapped_links.each do |link|
        link.fulltext = false if link.link_text == 'View on content provider\'s site'
      end
    end

    mapped_links
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
      return map[:category] if map.present? # matches a label exactly

      [/Access URL/i, /Availability/i].each do |excluded| # always exclude these labels
        return nil if label&.match?(excluded)
      end
      LINK_MAPPING[:open_access_link][:category] # the rest are open-access
    end

    def to_searchworks_link(categories = [])
      Links::Link.new(
        link_text: label,
        href:      url,
        fulltext:  present? && show?(categories, category),
        ill:       ill?,
        type:,
        stanford_only: pdf? || type == 'other'
      )
    end

    # Link types are prioritized as follows:
    #
    # 1 and 2 are preferred, and can coexist
    # show 3 only if there's no 1 or 2
    # show 4 only if there's no 1-3.
    # show 5 only if there's no 1-4
    #
    # @param [Array<Integer>] `all_categories`
    # @param [Integer] `category`
    # @param String `label`
    def show?(categories, category)
      case category
      when 1, 2
        true
      when 3, 4, 5
        categories.none? { |i| i < category }
      end
    end

    private

    # Primarily an EDS-label based mapping
    LINK_MAPPING = {
      'HTML full text'.downcase =>           { label: 'View full text', category: 1 },
      'PDF full text'.downcase =>            { label: 'View/download PDF', category: 2 },
      'PDF eBook Full Text'.downcase =>      { label: 'View/download PDF', category: 2 },
      'EDS Full text'.downcase =>            { label: 'View on content provider\'s site', category: 3 },
      'Full text'.downcase =>                { label: 'View on content provider\'s site', category: 4 },
      :open_access_link =>                   { label: :as_is, category: 4 },
      'View request options'.downcase =>     { label: 'Find full text or request', category: 5 }
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
