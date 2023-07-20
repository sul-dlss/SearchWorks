class LocationRequestLinkComponent < ViewComponent::Base # rubocop:disable Metrics/ClassLength
  attr_reader :document, :library, :location, :items, :link_params

  # @params [SolrDocument] document
  # @params [String] library the code for the library with the holdings
  # @params [String] location the code for location with the holdings
  def self.for(document:, library:, location:, **kwargs)
    link_type = case library
                when 'HOOVER'
                  RequestLinks::HooverRequestLinkComponent
                when 'HV-ARCHIVE'
                  RequestLinks::HooverArchiveRequestLinkComponent
                when 'HOPKINS'
                  RequestLinks::HopkinsRequestLinkComponent
                else
                  LocationRequestLinkComponent
                end

    link_type.new(document:, library:, location:, **kwargs)
  end

  def initialize(document:, library:, location:, items: [], classes: %w[btn btn-default btn-xs request-button], **link_params)
    super

    @document = document
    @library = library
    @location = location
    @items = items

    @classes = classes
    @link_params = link_params

    @render = nil
  end

  def call
    link_to link_href, rel: 'nofollow noopener', target: '_blank', title: 'Opens in new tab', class: @classes.join(' '), **link_params do
      safe_join([
        external_link_icon,
        link_text,
        tag.span(' (opens in new tab)', class: 'sr-only')
      ], '')
    end
  end

  def render?
    return false unless items.any? && !bound_with?
    return @render unless @render.nil?

    return folio_pageable? if folio_items?

    @render = ((in_enabled_location? && any_items_circulate?) || in_mediated_pageable_location? || aeon_pageable?) &&
              !all_in_disabled_current_location?
  end

  private

  def link_href
    helpers.request_url(
      @document,
      library: @library,
      location: @location
    )
  end

  def external_link_icon
    tag.span('', class: 'bi bi-box-arrow-up-right', aria: { hidden: true })
  end

  def link_text
    return I18n.t('searchworks.request_link.finding_aid') if finding_aid? && aeon_pageable?
    return I18n.t('searchworks.request_link.aeon') if aeon_pageable?

    t("searchworks.request_link.#{@library}", default: [:'searchworks.request_link.default'])
  end

  def finding_aid?
    document&.index_links&.finding_aid&.first&.href.present?
  end

  def bound_with?
    Constants::BOUND_WITH_LOCS.include?(location)
  end

  def in_enabled_location?
    in_mediated_pageable_location? ||
      Settings.pageable_locations[library] == '*' ||
      Settings.pageable_locations[library]&.include?(location)
  end

  def in_mediated_pageable_location?
    Settings.mediated_locations[library] == '*' ||
      Settings.mediated_locations[library]&.include?(location)
  end

  def aeon_pageable?
    return folio_aeon_pageable? if folio_items?

    Settings.aeon_locations[library] == '*' ||
      Settings.aeon_locations.dig(library, location) == "*" ||
      items.all? do |item|
        Settings.aeon_locations.dig(library, location)&.include?(item.type)
      end
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
