# frozen_string_literal: true

class LocationRequestLinkComponent < ViewComponent::Base
  attr_reader :document, :library_code, :location, :link_params

  # @params [SolrDocument] document
  # @params [String] library_code the code for the library with the holdings
  # @params [Holdings::Location] location the location with the holdings
  def self.for(document:, library_code:, location:, **)
    link_type = case library_code
                when 'HILA'
                  RequestLinks::HooverRequestLinkComponent
                else
                  LocationRequestLinkComponent
                end

    link_type.new(document:, library_code:, location:, **)
  end

  def initialize(document:, library_code:, location:, hide_icon: false, classes: %w[btn btn-xs request-button], **link_params)
    super()

    @document = document
    @library_code = library_code
    @location = location

    @classes = classes
    @link_params = link_params
    @hide_icon = hide_icon

    @render = nil
  end

  def call
    link_to link_href, rel: 'nofollow noopener', target: '_blank', title: 'Opens in new tab', class: @classes.join(' '), **link_params do
      safe_join([
        external_link_icon,
        link_text,
        tag.span(' (opens in new tab)', class: 'visually-hidden')
      ].compact, '')
    end
  end

  def render?
    @render ||= policy.show?
  end

  private

  def policy
    @policy ||= LocationRequestLinkPolicy.new(location:, library_code:)
  end

  def link_href
    helpers.request_url(
      document,
      library: library_code,
      location: location.code
    )
  end

  def external_link_icon
    return if @hide_icon

    tag.span('', class: 'bi bi-box-arrow-up-right', aria: { hidden: true })
  end

  def link_text
    return I18n.t('searchworks.request_link.finding_aid') if has_finding_aid? && policy.aeon_pageable?
    return I18n.t('searchworks.request_link.aeon') if policy.aeon_pageable?

    t("searchworks.request_link.#{library_code}", default: [:'searchworks.request_link.default'])
  end

  delegate :has_finding_aid?, to: :document
end
