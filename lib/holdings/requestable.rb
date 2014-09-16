class Holdings
  class Requestable
    def initialize(callnumber)
      @callnumber = callnumber
    end

    def requestable?
      !location_level_request? && item_is_requestable?
    end

    def must_request?
      requestable? && must_request_item?
    end

    private

    def item_is_requestable?
      requestable_item_type? &&
      requestable_home_location? &&
      requestable_current_location?
    end

    def must_request_item?
      !location_level_request? && must_request_current_location?
    end

    def must_request_current_location?
      current_location_is_loan_desk? ||
      Constants::REQUESTABLE_CURRENT_LOCS.include?(@callnumber.current_location.code) ||
      Constants::UNAVAILABLE_CURRENT_LOCS.include?(@callnumber.current_location.code)
    end

    def requestable_item_type?
      !@callnumber.type.start_with?('NH-') &&
      !["REF","NONCIRC","LIBUSEONLY"].include?(@callnumber.type)
    end

    def requestable_home_location?
      !green_media_microtext? &&
      !Constants::NON_REQUESTABLE_HOME_LOCS.include?(@callnumber.home_location)
    end

    def green_media_microtext?
      @callnumber.library == "GREEN" && @callnumber.home_location == "MEDIA-MTXT"
    end

    def requestable_current_location?
      !Constants::NON_REQUESTABLE_CURRENT_LOCS.include?(@callnumber.current_location.code)
    end

    def location_level_request?
      Constants::REQUEST_LIBS.include?(@callnumber.library) ||
      ["PHYSICS", "MEYER"].include?(@callnumber.library) ||
      Holdings::Location.new(@callnumber.home_location).location_level_request?
    end

    def current_location_is_loan_desk?
      @callnumber.current_location.code.end_with?('-LOAN') && @callnumber.current_location.code != "SEE-LOAN"
    end
  end
end
