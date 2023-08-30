# This determines whether we should display a request link to the user
class LocationRequestLinkPolicy
  def initialize(location:, library:, items:)
    @location = location
    @library = library
    @items = items
  end

  def show?
    return false unless items.any? && !bound_with_or_analyzed_serial?

    return folio_pageable? if folio_items?

    (
      (in_enabled_location? && any_items_circulate?) ||
      in_mediated_pageable_location? || aeon_pageable?
    ) && !all_in_disabled_current_location?
  end

  def aeon_pageable?
    return folio_aeon_pageable? if folio_items?

    Settings.aeon_locations[library] == '*' ||
      Settings.aeon_locations.dig(library, location) == "*" ||
      items.all? do |item|
        Settings.aeon_locations.dig(library, location)&.include?(item.type)
      end
  end

  private

  attr_reader :location, :library, :items

  def in_enabled_location?
    in_mediated_pageable_location? ||
      Settings.pageable_locations[library] == '*' ||
      Settings.pageable_locations[library]&.include?(location)
  end

  def in_mediated_pageable_location?
    Settings.mediated_locations[library] == '*' ||
      Settings.mediated_locations[library]&.include?(location)
  end

  def any_items_circulate?
    return true if items.blank?

    items.any?(&:circulates?)
  end

  def all_in_disabled_current_location?
    return false if items.blank?

    items.all? do |item|
      disabled_current_locations.include?(item.current_location.code)
    end
  end

  def disabled_current_locations
    Settings.disabled_current_locations[library] || Settings.disabled_current_locations.default
  end

  # This method returns true for 3 cases
  # 1. The item is "Bound-with" in folio (determined by holdingsType.name, e.g. a86041)
  # 2. The item is a analyzed serial (determined by a SEE-OTHER folio location)
  # 3. The item is a bound with that wasn't migrated correctly (determined by a *-SEE-OTHER folio location, e.g. a85550, a75525)
  def bound_with_or_analyzed_serial?
    folio_bound_with_or_analyzed_serial? ||
      Constants::BOUND_WITH_LOCS.include?(location) # Legacy Symphony method. This can be removed after migration.
  end

  def folio_bound_with_or_analyzed_serial?
    (!folio_items? && items.first.document&.folio_holdings&.any?(&:bound_with?)) ||
      (folio_items? && items.any? { |item| item.effective_location&.see_other? })
  end

  def folio_items?
    items.any?(&:folio_item?)
  end

  def folio_pageable?
    !folio_disabled_status_location? &&
      (folio_mediated_pageable? ||
        folio_aeon_pageable? ||
          folio_item_pageable?)
  end

  # Special cases where we don't allow requests for special collections items in certain statuses
  def folio_disabled_status_location?
    return false unless library == 'SPEC-COLL'

    items.all? { |item| [Constants::FolioStatus::MISSING, Constants::FolioStatus::IN_PROCESS].include?(item.folio_status) }
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
    items.uniq(&:request_policy_attributes).any? do |item|
      item.request_policy&.dig('requestTypes')&.include?('Page')
    end
  end

  # there probably is only one FOLIO location.
  def folio_permanent_locations
    @folio_permanent_locations ||= items.filter_map(&:permanent_location).uniq(&:id).map(&:cached_location_data)
  end
end
