class LocationRequestLinkComponent < ViewComponent::Base
  attr_reader :document, :library, :location, :items, :link_params

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

    link_type.new(document: document, library: library, location: location, **kwargs)
  end

  def initialize(document:, library:, location:, items: [], classes: %w[btn btn-default btn-xs request-button], **link_params)
    super

    @document = document
    @library = library
    @location = location
    @items = items

    @classes = classes
    @link_params = link_params
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

    ((in_enabled_location? && any_items_circulate?) || in_mediated_pageable_location? || aeon_pageable?) &&
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
end
