class Holdings
  class Location
    attr_reader :code, :items, :mhld

    def initialize(code, items = [], mhld = [])
      @code = code
      @items = items.sort_by(&:full_shelfkey)
      @mhld = mhld
    end

    def name
      return if @code.blank?

      Constants::LOCS.fetch(@code, @code)
    end

    def bound_with?
      @code && Constants::BOUND_WITH_LOCS.include?(@code)
    end

    def external_location?
      library == 'LANE-MED'
    end

    def request_link
      return if items.empty? || bound_with?

      @request_link ||= RequestLink.for(library: library, location: @code, items: items)
    end

    def location_link
      return unless external_location?

      if items.first.try(:barcode)
        "https://lane.stanford.edu/view/bib/#{items.first.barcode.gsub(/^LL/, '')}"
      else
        'https://lane.stanford.edu'
      end
    end

    def present?
      any_items? || any_mhlds? || bound_with?
    end

    def present_on_index?
      any_items? || any_index_mhlds? || @code == 'SEE-OTHER'
    end

    def sort
      name || @code
    end

    def as_json
      {
        code: code,
        items: items.select(&:present?).map(&:as_json),
        mhld: mhld&.select(&:present?)&.map(&:as_json),
        name: name
      }
    end

    private

    def library
      if any_items?
        items.first.library
      elsif any_mhlds?
        mhld.first.library
      end
    end

    def sanitized_library
      library.downcase.gsub('-', '_') if library
    end

    def any_items?
      items.any?(&:present?)
    end

    def any_mhlds?
      mhld.present? && mhld.any?(&:present?)
    end

    def any_index_mhlds?
      mhld.present? && mhld.any? do |mhld_item|
        mhld_item.latest_received.present? ||
          mhld_item.public_note.present?
      end
    end
  end
end
