# frozen_string_literal: true

##
# A mixin to add dynamic libary specific location facet support
module LocationFacet
  SUBLOCATION_LIBRARIES = %w[ART EDUCATION].freeze

  extend ActiveSupport::Concern

  included do
    before_action :redirect_legacy_building_facet, only: :index
    before_action :add_location_facet, only: [:index, :facet]
  end

  protected

  def redirect_legacy_building_facet
    return unless params[:f] && params[:f][:building_facet]

    legacy_names = params[:f].delete(:building_facet)
    library_codes = legacy_names.filter_map do |name|
      next 'SDR' if name == 'Stanford Digital Repository'

      Folio::Types.libraries.values.find { it['name'].start_with?(name) || it['name'].sub(' Library', '').start_with?(name) }&.fetch('code')
    end

    return unless library_codes.first

    new_state = search_state.add_facet_params_and_redirect('library', library_codes.first)

    redirect_to search_catalog_path(new_state.to_h)
  end

  def add_location_facet
    return unless library_code_facet_includes_library_with_sublocation?

    blacklight_config.facet_fields['location_facet'].tap do |facet|
      facet.show = true
      facet.if = true
    end
  end

  def library_code_facet_includes_library_with_sublocation?
    params[:f] &&
      params[:f][:library] &&
      Array.wrap(params[:f][:library]).any? do |facet|
        SUBLOCATION_LIBRARIES.include?(facet)
      end
  end
end
