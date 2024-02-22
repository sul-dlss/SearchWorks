# This determines whether we should display a request link to the user
class LocationRequestLinkPolicy
  def initialize(location:, library:, items:)
    @location = location
    @library = library
    @items = items
  end

  def show?
    return false if items.none? || bound_with?

    folio_pageable?
  end

  def aeon_pageable?
    folio_aeon_pageable? if folio_items?
  end

  private

  attr_reader :location, :library, :items

  # @return [Bool] true if the item is a Bound-with child in folio
  def bound_with?
    items.first.document&.folio_holdings&.any?(&:bound_with?)
  end

  def folio_items?
    items.any?(&:folio_item?)
  end

  def folio_pageable?
    return false unless folio_items?

    !folio_disabled_status_location? &&
      (folio_mediated_pageable? ||
        folio_aeon_pageable? ||
          folio_item_pageable?)
  end

  # Special cases where we don't allow requests for special collections items in certain statuses
  def folio_disabled_status_location?
    return false unless library == 'SPEC-COLL'

    items.all? do |item|
      Constants::FolioStatus::UNPAGEABLE_SPEC_COLL_STATUSES.include?(item.folio_status) ||
        item.effective_location&.details&.dig('availabilityClass') == 'In_process_non_requestable'
    end
  end

  def folio_mediated_pageable?
    return false unless folio_items? && folio_permanent_locations.any?

    folio_permanent_locations.all? { |location| location.dig('details', 'pageMediationGroupKey') }
  end

  def folio_aeon_pageable?
    return false unless folio_items? && folio_permanent_locations.any?

    folio_permanent_locations.all? { |location| location.dig('details', 'pageAeonSite') }
  end

  def folio_item_pageable?
    items.any? do |item|
      item.allowed_request_types&.include?('Page')
    end
  end

  # there probably is only one FOLIO location.
  def folio_permanent_locations
    @folio_permanent_locations ||= items.filter_map(&:permanent_location).uniq(&:id).map(&:cached_location_data)
  end
end
