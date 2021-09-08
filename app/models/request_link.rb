# frozen_string_literal: true

##
# A model to represent data necessary for rendering a request link
class RequestLink
  attr_reader :document, :library, :location, :items
  def initialize(document:, library:, location:, items: [])
    @document = document
    @library = library
    @location = location
    @items = items
  end

  def self.for(document:, library:, location:, items: [])
    RequestLinkFactory.for(
      library: library, location: location
    ).new(document: document, library: library, location: location, items: items)
  end

  def present?
    ((in_enabled_location? && any_items_circulate?) || mediated_pageable?) &&
      !all_in_disabled_current_location? &&
      !available_via_temporary_access?
      # Check for real barcodes?  Only for items that are not on-order?
      # Array of procs / methods to be sent configurable on a library basis.
  end

  def render
    return '' unless present?

    markup.html_safe
  end

  def url
    "#{base_request_url}?#{request_params.to_query}"
  end

  private

  def available_via_temporary_access?
    document&.access_panels&.temporary_access&.present?
  end

  def classes
    'btn btn-default btn-xs request-button'
  end

  def markup
    "<a href=\"#{url}\" rel=\"nofollow\" target=\"_blank\" title=\"Opens in new tab\" class=\"#{classes}\">#{link_text} <span class=\"sr-only\">(opens in new tab)</span></a>"
  end

  def base_request_url
    Settings.REQUESTS_URL
  end

  def request_params
    {
      item_id: document[:id],
      origin: library,
      origin_location: location
    }
  end

  def link_text
    library_map = link_text_map[library]

    return link_text_map['default'] unless library_map
    return library_map if library_map.is_a?(String)

    library_map[location] || library_map
  end

  def link_text_map
    {
      'SPEC-COLL' => 'Request on-site access',
      'default' => 'Request'
    }
  end

  def in_enabled_location?
    Settings.pageable_locations[library] == '*' ||
      Settings.pageable_locations[library]&.include?(location)
  end

  def all_in_disabled_current_location?
    items.all? do |item|
      disabled_current_locations.include?(item.current_location.code)
    end
  end

  def disabled_current_locations
    library_map = disabled_current_locations_map[library]

    library_map || disabled_current_locations_map['default']
  end

  def any_items_circulate?
    return true if circulating_item_types == '*'

    items.any? { |item| circulating_item_types.include?(item.type) }
  end

  def circulating_item_types
    library_map = Settings.circulating_item_types[library]

    return Settings.circulating_item_types['default'] unless library_map
    return library_map if library_map.is_a?(Array)

    library_map[location] || library_map['default'] || library_map
  end

  def mediated_pageable?
    Settings.mediated_locations[library] == '*' ||
      Settings.mediated_locations[library]&.include?(location)
  end

  def disabled_current_locations_map
    {
      'SPEC-COLL' => %w[INPROCESS MISSING ON-ORDER SPEC-INPRO],
      'default' => %w[]
    }
  end
end
