class Holdings
  class Location
    attr_reader :code, :items, :mhld

    def initialize(code, items = [], document = nil, mhld = [])
      @code = code
      @document = document
      @items = items.sort_by(&:full_shelfkey)
      @mhld = mhld
    end

    def name
      Constants::LOCS[@code]
    end

    def bound_with?
      @code && Constants::BOUND_WITH_LOCS.include?(@code)
    end

    def external_location?
      library == 'LANE-MED'
    end

    def request_link
      return if items.empty? || bound_with?

      @request_link ||= RequestLink.for(document: @document, library: library, location: @code, items: items)
    end

    def location_link
      return unless external_location?

      if items.first.try(:barcode)
        "http://lmldb.stanford.edu/cgi-bin/Pwebrecon.cgi?DB=local&Search_Arg=SOCW+#{items.first.barcode.gsub(/^L/, '')}&Search_Code=CMD*&CNT=10"
      else
        'http://lmldb.stanford.edu'
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
