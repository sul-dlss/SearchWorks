module EdsLinks
  def eds_links
    @eds_links ||= EdsLinks::Processor.new(self)
  end

  # EDS-centric full text link
  class FulltextLink
    attr_reader :url, :type, :label
    def initialize(link_fields)
      link_fields = link_fields.symbolize_keys
      @url = link_fields[:url]
      @original_label = link_fields[:label]
      @type = link_fields[:type]
      @label = relabel
    end

    def present?
      %w[customlink-fulltext pdf ebook-pdf ebook-epub].include?(type) && label.present?
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
        return nil if label =~ excluded
      end
      LINK_MAPPING[:open_access_link][:category] # the rest are open-access
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

  # Maps EDS-centric links into SearchWorks links
  class Processor < SearchWorks::Links
    # @return [Array<SearchWorks::Links::Link>]
    def all
      # First convert into our FulltextLink objects
      links = link_fields.map do |link_field|
        EdsLinks::FulltextLink.new(link_field)
      end

      # Ensure they meet our requirements
      links.select!(&:present?)

      # Then, map them into the SearchWorks objects
      categories = links.map(&:category).compact.map(&:to_i)
      links.map do |link|
        SearchWorks::Links::Link.new(
          text:     link.label,
          href:     link.url,
          fulltext: link.present? && show?(categories, link.category),
          sfx:      link.sfx?,
          ill:      link.ill?,
          type:     link.type
        )
      end
    end

    private

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

    def link_fields
      @document['eds_fulltext_links'] || []
    end
  end
end
