# This determines whether we should display a request link to the user
class RequestLinkPolicy
  def initialize(location:, library:, items:)
    @location = location
    @library = library
    @items = items
  end

  def show?
    return false unless items.any? && !bound_with?

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

  def bound_with?
    Constants::BOUND_WITH_LOCS.include?(location)
  end

  def folio_items?
    items.first.folio_item?
  end

  def folio_pageable?
    return false unless folio_items?

    !folio_disabled_status_location? &&
      (folio_mediated_pageable? ||
        folio_aeon_pageable? ||
         Folio::CirculationRules::PolicyService.instance.item_request_policy(items.first)&.dig('requestTypes')&.include?('Page'))
  end

  # Special cases where we don't allow requests for special collections items in certain statuses
  def folio_disabled_status_location?
    return false unless library == 'SPEC-COLL'

    items.all? { |item| [Constants::FolioStatus::MISSING, Constants::FolioStatus::IN_PROCESS].include?(item.folio_status) }
  end

  def folio_mediated_pageable?
    return false unless folio_items? && folio_locations.any?

    folio_locations.all? { |location| location.dig('details', 'pageMediationGroupKey') }
  end

  def folio_aeon_pageable?
    return false unless folio_items? && folio_locations.any?

    folio_locations.all? { |location| location.dig('details', 'pageAeonSite') }
  end

  # there probably is only one FOLIO location
  def folio_locations
    @folio_locations ||= begin
      location_uuids = items.map(&:effective_location).map(&:id).uniq

      Folio::Types.locations.values.select { |l| location_uuids.include?(l['id']) }
    end
  end
end
