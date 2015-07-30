class Holdings
  class Location
    attr_reader :code, :items
    attr_accessor :mhld
    def initialize(code, items = [])
      @code = code
      @items = items.sort_by(&:full_shelfkey)
    end

    def name
      send("#{sanitized_library}_specific_location_name".to_sym)
    end

    def bound_with?
      @code && @code == 'SEE-OTHER'
    end

    def location_level_request?
      !contains_only_must_request_items? &&
        !spec_coll_only_inprocess? &&
        (Constants::LOCATION_LEVEL_REQUEST_LOCS.include?(@code) || Constants::REQUEST_LOCS.include?(@code))
    end

    def external_location?
      library == 'LANE-MED'
    end

    def location_link
      return unless external_location?
      if items.first.try(:barcode)
        "http://lmldb.stanford.edu/cgi-bin/Pwebrecon.cgi?DB=local&Search_Arg=SOCW+#{items.first.barcode.gsub(/^L/,'')}&Search_Code=CMD*&CNT=10"
      else
        'http://lmldb.stanford.edu'
      end
    end

    def present?
      any_items? || any_mhlds?
    end

    def present_on_index?
      any_items? || any_index_mhlds?
    end

    def sort
      name || @code
    end

    def as_json(*)
      methods = (public_methods(false) - [:as_json, :items, :mhld])
      location_info = methods.each_with_object({}) do |meth, obj|
        obj[meth.to_sym] = send(meth) if method(meth).arity == 0
      end
      location_info[:items] = items.select(&:present?).map(&:as_json)
      location_info[:mhld] = mhld.select(&:present?).map(&:as_json) if mhld
      location_info
    end

    private

    def spec_coll_only_inprocess?
      return false unless @items.present?
      library == 'SPEC-COLL' && @items.all? do |item|
        item.current_location.try(:code) == 'INPROCESS'
      end
    end

    def contains_only_must_request_items?
      @items.present? && @items.all?(&:must_request?)
    end

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

    def green_specific_location_name
      Constants::LOCS.merge(Constants::GREEN_SPECIFIC_LOCS)[@code]
    end

    def spec_coll_specific_location_name
      Constants::LOCS.merge(Constants::SPEC_SPECIFIC_LOCS)[@code]
    end

    def method_missing(method_name, *args, &block)
      case method_name
      when /#{sanitized_library}_specific_location_name/
        Constants::LOCS[@code]
      else
        super
      end
    end
  end
end
