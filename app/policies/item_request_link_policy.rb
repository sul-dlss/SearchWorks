# This determines whether we should display a request link to the user
class ItemRequestLinkPolicy
  def initialize(item:)
    @item = item
  end

  def show?
    return folio_pageable? if item.folio_item?

    return false if aeon_pageable? || in_mediated_pageable_location? || in_nonrequestable_location? || item.on_reserve?

    current_location_is_always_requestable?
  end

  private

  attr_reader :item

  delegate :document, :library, :home_location, :barcode, to: :item

  def current_location
    item.current_location.code
  end

  def folio_pageable?
    return false if folio_aeon_pageable? || folio_mediated_pageable? || item.on_reserve?

    Folio::CirculationRules::PolicyService.instance.item_request_policy(item)&.dig('requestTypes')&.include?('Page')
  end

  def folio_location
    @folio_location ||= Folio::Types.locations.values.find { |l| item.effective_location.id == l['id'] }
  end

  def folio_aeon_pageable?
    return false unless folio_location

    folio_location.dig('details', 'pageAeonSite')
  end

  def folio_mediated_pageable?
    return false unless folio_location

    folio_location.dig('details', 'pageMediationGroupKey')
  end

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

  def in_nonrequestable_location?
    (Settings.nonrequestable_locations[library] || Settings.nonrequestable_locations.default).include?(home_location)
  end

  def current_location_is_always_requestable?
    return true if current_location.end_with?('-LOAN') && current_location != "SEE-LOAN"

    (Settings.requestable_current_locations[library] || Settings.requestable_current_locations.default).include?(current_location) ||
      (Settings.unavailable_current_locations[library] || Settings.unavailable_current_locations.default).include?(current_location)
  end
end
