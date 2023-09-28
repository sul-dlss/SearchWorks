class LocationRequestLinkComponent < ViewComponent::Base
  attr_reader :document, :library, :location, :items, :link_params

  # @params [SolrDocument] document
  # @params [String] library the code for the library with the holdings
  # @params [String] location the code for location with the holdings
  def self.for(document:, library:, location:, **kwargs)
    link_type = case library
                when 'HOOVER', 'HV-ARCHIVE', 'HILA'
                  if document&.index_links&.finding_aid&.first&.href
                    RequestLinks::HooverArchiveRequestLinkComponent
                  else
                    RequestLinks::HooverRequestLinkComponent
                  end
                else
                  LocationRequestLinkComponent
                end

    link_type.new(document:, library:, location:, **kwargs)
  end

  def initialize(document:, library:, location:, items: [], classes: %w[btn btn-xs request-button], **link_params)
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
    @render ||= policy.show?
  end

  private

  def policy
    @policy ||= LocationRequestLinkPolicy.new(location:, library:, items:)
  end

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
    return I18n.t('searchworks.request_link.finding_aid') if has_finding_aid? && policy.aeon_pageable?
    return I18n.t('searchworks.request_link.aeon') if policy.aeon_pageable?

    t("searchworks.request_link.#{@library}", default: [:'searchworks.request_link.default'])
  end

  delegate :has_finding_aid?, to: :document
end
