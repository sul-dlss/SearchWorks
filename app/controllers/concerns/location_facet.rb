# frozen_string_literal: true

##
# A mixin to add dynamic libary specific location facet support
module LocationFacet
  SUBLOCATION_LIBRARIES = ['ART', 'EDUCATION'].freeze

  extend ActiveSupport::Concern

  included do
    if respond_to?(:before_action)
      before_action :add_location_facet, only: [:index, :facet]
    end
  end

  protected

  def add_location_facet
    return unless library_code_facet_includes_library_with_sublocation?

    blacklight_config.facet_fields['location_facet'].tap do |facet|
      facet.show = true
      facet.if = true
    end
  end

  def library_code_facet_includes_library_with_sublocation?
    params[:f] &&
      params[:f][:library_code_facet_ssim] &&
      Array.wrap(params[:f][:library_code_facet_ssim]).any? do |facet|
        SUBLOCATION_LIBRARIES.include?(facet)
      end
  end
end
