class Holdings
  class Location
    attr_reader :code, :items
    attr_accessor :mhld
    def initialize(code, items = [], document = nil)
      @code = code
      @document = document
      @items = items.sort_by(&:full_shelfkey)
    end

    def name
      Constants::LOCS[@code]
    end

    def bound_with?
      @code && Constants::BOUND_WITH_LOCS.include?(@code)
    end

    def location_level_request?
      !contains_only_must_request_items? &&
        !noncirc_library_only_inprocess? &&
        !reserve_location? &&
        (Constants::LOCATION_LEVEL_REQUEST_LOCS.include?(@code) ||
         Constants::REQUEST_LOCS.include?(@code) ||
         hopkins_stacks_only_and_not_online?)
    end

    def external_location?
      library == 'LANE-MED'
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

    def as_json(live_data = [])
      methods = (public_methods(false) - [:as_json, :items, :mhld])
      location_info = methods.each_with_object({}) do |meth, obj|
        obj[meth.to_sym] = send(meth) if method(meth).arity == 0
      end
      present_items = items.select(&:present?)
      present_items.map do |item|
        live_data_string = live_data_for_barcode(live_data, item.barcode)
        live_data_barcode = JSON.parse(live_data_string) if live_data_string.present?
        if live_data_barcode.present?
          item.current_location = Holdings::Location.new(live_data_barcode['current_location']).as_json
          item.due_date = live_data_barcode['due_date'] if live_data_barcode['due_date']
          item.status = Holdings::Status.new(item)
        end
      end
      location_info[:items] = present_items.map(&:as_json)
      location_info[:mhld] = mhld.select(&:present?).map(&:as_json) if mhld
      location_info
    end

    def reserve_location?
      (@code || '').ends_with?('-RESV')
    end

    private

    def hopkins_stacks_only_and_not_online?
      hopkins_only? && hopkins_stacks? && !document_online?
    end

    def hopkins_only?
      hopkins? &&
        @document.present? &&
        @document.holdings.libraries.present? &&
        @document.holdings.libraries.length == 1
    end

    def hopkins?
      library == 'HOPKINS'
    end

    def hopkins_stacks?
      hopkins? && @code && @code == 'STACKS'
    end

    def hopkins_and_not_online?
      hopkins? && !document_online?
    end

    def document_online?
      @document.present? && @document.access_panels.online?
    end

    def noncirc_library_only_inprocess?
      return false unless @items.present?

      Constants::INPROCESS_NONCIRC_LIBRARIES.include?(library) && @items.all? do |item|
        Constants::INPROCESS_NONCIRC_LOCS.include?(item.current_location.try(:code))
      end
    end

    def contains_only_must_request_items?
      @items.present? && @items.all?(&:must_request?)
    end

    def live_data_for_barcode(data, barcode)
      data.find do |item|
        JSON.parse(item)['barcode'] == barcode
      end
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
  end
end
