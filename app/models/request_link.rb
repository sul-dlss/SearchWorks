# frozen_string_literal: true

##
# A model to represent data necessary for rendering a request link
class RequestLink
  include ActionView::Helpers::TagHelper

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

  def show_location_level_request_link?
    ((in_enabled_location? && any_items_circulate?) || mediated_pageable?) &&
      !all_in_disabled_current_location? &&
      !available_via_temporary_access?
      # Check for real barcodes?  Only for items that are not on-order?
      # Array of procs / methods to be sent configurable on a library basis.
  end

  NEVER = false
  ALWAYS = true
  DEPENDS_ON_AVAILABILITY = 2
  def show_item_level_request_link?(item)
    return NEVER if show_location_level_request_link? || mediated_pageable? || nonrequestable_location? || item.on_reserve?

    if current_location_is_always_requestable?(item)
      ALWAYS # always show it
    elsif item_circulates?(item)
      DEPENDS_ON_AVAILABILITY # depends on availability info
    else
      NEVER
    end
  end

  def render
    return '' unless show_location_level_request_link?

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
    tag.a safe_join([link_text, tag.span(' (opens in new tab)', class: 'sr-only')], ''), href: url, rel: 'nofollow', target: '_blank', title: 'Opens in new tab', class: classes, **link_params
  end

  def link_params
    {}
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

  def nonrequestable_location?
    (Settings.nonrequestable_locations[library] || Settings.nonrequestable_locations.default).include?(location)
  end

  def all_in_disabled_current_location?
    return false if items.blank?

    items.all? do |item|
      disabled_current_locations.include?(item.current_location.code)
    end
  end

  def disabled_current_locations
    library_map = disabled_current_locations_map[library]

    library_map || disabled_current_locations_map['default']
  end

  def any_items_circulate?
    return true if items.blank?

    items.any? { |item| item_circulates?(item) }
  end

  def item_circulates?(item)
    circulating_item_types == '*' || circulating_item_types.include?(item.type)
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

  def current_location_is_always_requestable?(item)
    current_location = item.current_location.code

    return true if current_location.end_with?('-LOAN') && current_location != "SEE-LOAN"

    (Settings.requestable_current_locations[library] || Settings.requestable_current_locations.default).include?(current_location) ||
      (Settings.unavailable_current_locations[library] || Settings.unavailable_current_locations.default).include?(current_location)
  end

  def disabled_current_locations_map
    {
      'SPEC-COLL' => %w[INPROCESS MISSING ON-ORDER SPEC-INPRO],
      'default' => %w[]
    }
  end
end
