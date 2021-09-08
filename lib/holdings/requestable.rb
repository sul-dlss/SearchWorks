class Holdings
  class Requestable
    attr_reader :callnumber

    delegate :document, :library, :home_location, :current_location, :type, :on_reserve?, to: :callnumber

    def initialize(callnumber)
      @callnumber = callnumber
    end

    # Is it even remotely plausible to request the item?
    def requestable?
      return false if location_level_request_link? || on_reserve? || mediated_location? || nonrequestable_home_location?

      current_location_is_loan_desk? || circulates?
    end

    # Is the item somewhere where we need to show an item-level request link regardless of the
    # availability check?
    def show_item_level_request_link?
      requestable? && (current_location_is_loan_desk? || must_request_current_location?)
    end

    private

    def location_level_request_link?
      RequestLink.for(document: document, library: library, location: home_location).present?
    end

    def circulates?
      circulating_item_types.include? type
    end

    def mediated_location?
      Settings.mediated_locations[library] == '*' ||
        Settings.mediated_locations[library]&.include?(home_location)
    end

    def nonrequestable_home_location?
      Constants::NON_REQUESTABLE_HOME_LOCS.include?(home_location)
    end

    def current_location_is_loan_desk?
      current_location.code.end_with?('-LOAN') && current_location.code != "SEE-LOAN"
    end

    def must_request_current_location?
      Constants::REQUESTABLE_CURRENT_LOCS.include?(current_location.code) ||
        Constants::UNAVAILABLE_CURRENT_LOCS.include?(current_location.code)
    end

    def circulating_item_types
      library_map = Settings.circulating_item_types[library]

      return Settings.circulating_item_types['default'] unless library_map
      return library_map if library_map.is_a?(Array)

      library_map[home_location] || library_map['default'] || library_map
    end
  end
end
