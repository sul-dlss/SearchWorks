##
# A mixin to add dynamic genre specific facet support
module StanfordThesesFacet

  extend ActiveSupport::Concern

  included do
    if respond_to?(:before_action)
      before_action :add_stanford_theses_facet, only: [:index, :facet]
    end
  end

  protected

  def add_stanford_theses_facet
    return unless genre_facet_includes_thesis_value?
    blacklight_config.facet_fields['stanford_theses_facet_hsim'].tap do |facet|
      facet.show = true
      facet.if = true
    end
  end

  def genre_facet_includes_thesis_value?
    params[:f] &&
      params[:f][:genre_ssim] &&
      params[:f][:genre_ssim].any? do |facet|
        facet == 'Thesis/Dissertation'
      end
  end
end
