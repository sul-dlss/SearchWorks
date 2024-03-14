# frozen_string_literal: true

module EdsLinks
  def eds_links
    @eds_links ||= Links.new(eds_fulltext_links_as_searchworks_links)
  end

  private

  def eds_fulltext_links
    fetch('eds_fulltext_links', []).map do |link_field|
      EdsLinks::FulltextLink.new(link_field)
    end.select(&:present?)
  end

  def eds_fulltext_links_as_searchworks_links
    links = eds_fulltext_links

    categories = links.filter_map(&:category).map(&:to_i)

    links.map { |link| link.to_searchworks_link(categories) }
  end

  # EDS-centric full text link
  class FulltextLink
    attr_reader :url, :type, :label

    def initialize(link_field)
      link_field = link_field.symbolize_keys
      @url = link_field[:url]
      @original_label = link_field[:label]
      @type = link_field[:type]
      @label = relabel
    end

    def present?
      %w[customlink-fulltext pdf ebook-pdf ebook-epub].include?(type) && label.present?
    end

    def pdf?
      category == 2
    end

    def sfx?
      category == 3
    end

    def ill?
      category == 5
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
        sfx:       sfx?,
        ill:       ill?,
        type:,
        stanford_only: pdf?
      )
    end

    # Link types are prioritized as follows:
    #
    # 1 and 2 are preferred, and can coexist
    # show 3 only if there's no 1 or 2
    # show 4 only if there's no 1-3
    # show 5 only if there's no 1-4
    #
    # @param [Array<Integer>] `all_categories`
    # @param [Integer] `category`
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
      'Check SFX for full text'.downcase =>  { label: 'View on content provider\'s site', category: 3 },
      :open_access_link =>                   { label: :as_is, category: 4 },
      'View request options'.downcase =>     { label: 'Find full text or request', category: 5 }
    }.freeze

    def map
      LINK_MAPPING[@original_label.to_s.downcase] || {}
    end

    def relabel
      return map[:label] if map[:label].present? && map[:label] != :as_is

      @original_label
    end
  end
end
