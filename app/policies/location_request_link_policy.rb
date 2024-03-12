# frozen_string_literal: true

# This determines whether we should display a request link to the user
class LocationRequestLinkPolicy
  # @params [String] library_code the code for the library with the holdings
  # @params [Holdings::Location] location the code for location with the holdings
  def initialize(location:, library_code:)
    @location = location
    @library_code = library_code
  end

  def show?
    return false unless items.any? && !bound_with_or_analyzed_serial?

    folio_pageable?
  end

  def aeon_pageable?
    return false if !folio_items? || folio_permanent_locations.none? || folio_disabled_status_location?

    folio_permanent_locations.all? { |location| location.dig('details', 'pageAeonSite') }
  end

  private

  attr_reader :location, :library_code

  delegate :items, to: :location

  # 1. The item is "Bound-with" in folio (determined by holdingsType.name, e.g. a86041)
  # 2. The item is a analyzed serial (determined by a SEE-OTHER folio location)
  def bound_with_or_analyzed_serial?
    (!folio_items? && items.first.document&.folio_holdings&.any?(&:bound_with?)) ||
      (folio_items? && items.any? { |item| item.effective_location&.see_other? })
  end

  def folio_items?
    items.any?(&:folio_item?)
  end

  def folio_pageable?
    return false unless folio_items?

    !folio_disabled_status_location? &&
      (folio_mediated_pageable? ||
        aeon_pageable? ||
          folio_item_pageable?)
  end

  # Special cases where we don't allow requests for special collections items in certain statuses
  def folio_disabled_status_location?
    items.all? do |item|
      (library_code == 'SPEC-COLL' &&
        (Constants::FolioStatus::UNPAGEABLE_SPEC_COLL_STATUSES.include?(item.folio_status) ||
        item.effective_location&.details&.dig('availabilityClass') == 'In_process_non_requestable')) ||
        Settings.folio_unrequestable_statuses.include?(item.folio_status)
    end
  end

  def folio_mediated_pageable?
    return false unless folio_items? && folio_permanent_locations.any?

    folio_permanent_locations.all? { |location| location.dig('details', 'pageMediationGroupKey') }
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
