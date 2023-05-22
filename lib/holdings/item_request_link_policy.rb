class Holdings
  # This contains the business logic around whether to display an item level request link
  # This may say "no" even though an item is still requestable (aeon-paged or mediated-paged),
  # we just don't show an item-level link for it because the location-level link takes care of it.
  class ItemRequestLinkPolicy
    def initialize(item:)
      @item = item
    end

    delegate :current_location, :library, :home_location, :type, :on_reserve?, to: :@item

    def display?
      return false if aeon_pageable? || in_mediated_pageable_location? || in_nonrequestable_location? || on_reserve?

      current_location_is_always_requestable?
    end

    def current_location_is_always_requestable?
      return true if current_location.code.end_with?('-LOAN') && current_location.code != "SEE-LOAN"

      (Settings.requestable_current_locations[library] || Settings.requestable_current_locations.default).include?(current_location.code) ||
        (Settings.unavailable_current_locations[library] || Settings.unavailable_current_locations.default).include?(current_location.code)
    end

    def in_mediated_pageable_location?
      Settings.mediated_locations[library] == '*' ||
        Settings.mediated_locations[library]&.include?(home_location)
    end

    def aeon_pageable?
      Settings.aeon_locations[library] == '*' ||
        Settings.aeon_locations.dig(library, home_location) == "*" ||
        Settings.aeon_locations.dig(library, home_location)&.include?(type)
    end

    def in_nonrequestable_location?
      (Settings.nonrequestable_locations[library] || Settings.nonrequestable_locations.default).include?(home_location)
    end
  end
end
