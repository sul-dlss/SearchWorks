# This determines whether we should display a request link to the user
class ItemRequestLinkPolicy
  def initialize(item:)
    @item = item
  end

  def show?
    return false if aeon_pageable? || in_mediated_pageable_location? || in_nonrequestable_location? || item.on_reserve?

    current_location_is_always_requestable?
  end

  private

  attr_reader :item

  delegate :document, :library, :home_location, :barcode, to: :item

  def current_location
    item.current_location.code
  end

  # TODO: add folio stuff
  def aeon_pageable?
    Settings.aeon_locations[library] == '*' ||
      Settings.aeon_locations.dig(library, home_location) == "*" ||
      Settings.aeon_locations.dig(library, home_location)&.include?(item.type)
  end

  # TODO: This is same as LocationRequestLinkPolicy
  def in_mediated_pageable_location?
    Settings.mediated_locations[library] == '*' ||
      Settings.mediated_locations[library]&.include?(home_location)
  end

  # TODO: make like folio
  def in_nonrequestable_location?
    (Settings.nonrequestable_locations[library] || Settings.nonrequestable_locations.default).include?(home_location)
  end

  def current_location_is_always_requestable?
    return true if current_location&.end_with?('-LOAN') && current_location != "SEE-LOAN"

    (Settings.requestable_current_locations[library] || Settings.requestable_current_locations.default).include?(current_location) ||
      (Settings.unavailable_current_locations[library] || Settings.unavailable_current_locations.default).include?(current_location)
  end
end
