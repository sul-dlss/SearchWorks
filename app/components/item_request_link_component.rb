class ItemRequestLinkComponent < ViewComponent::Base
  delegate :document, :library, :home_location, :barcode, to: :@item

  def initialize(item:, classes: %w[btn btn-default btn-xs request-button])
    super

    @item = item
    @classes = classes
  end

  def call
    link_to(
      link_text,
      link_href,
      target: '_blank',
      rel: 'nofollow noopener',
      class: @classes.join(' ')
    )
  end

  def render?
    return false if aeon_pageable? || in_mediated_pageable_location? || in_nonrequestable_location? || @item.on_reserve?

    current_location_is_always_requestable?
  end

  private

  def link_href
    helpers.request_url(
      document,
      library: library,
      location: home_location,
      barcode: barcode
    )
  end

  def link_text
    locale_key = "searchworks.request_link.#{library || 'default'}"
    locale_key = 'searchworks.request_link.request_on_site' if Constants::REQUEST_ONSITE_LOCATIONS.include?(home_location)

    t(
      locale_key,
      default: :'searchworks.request_link.default'
    )
  end

  def current_location
    @item.current_location.code
  end

  def current_location_is_always_requestable?
    return true if current_location.end_with?('-LOAN') && current_location != "SEE-LOAN"

    (Settings.requestable_current_locations[library] || Settings.requestable_current_locations.default).include?(current_location) ||
      (Settings.unavailable_current_locations[library] || Settings.unavailable_current_locations.default).include?(current_location)
  end

  def in_mediated_pageable_location?
    Settings.mediated_locations[library] == '*' ||
      Settings.mediated_locations[library]&.include?(home_location)
  end

  def aeon_pageable?
    Settings.aeon_locations[library] == '*' ||
      Settings.aeon_locations.dig(library, home_location) == "*" ||
      Settings.aeon_locations.dig(library, home_location)&.include?(@item.type)
  end

  def in_nonrequestable_location?
    (Settings.nonrequestable_locations[library] || Settings.nonrequestable_locations.default).include?(home_location)
  end
end
