# frozen_string_literal: true

##
# A mixin to add dynamic genre specific facet support
module StanfordWorkFacet
  extend ActiveSupport::Concern

  included do
    if respond_to?(:before_action)
      before_action :add_stanford_work_facet, only: [:index, :facet]
      before_action :add_stanford_dept_facet, only: [:index, :facet]
    end
  end

  protected

  def add_stanford_work_facet
    return unless genre_facet_includes_thesis_value?

    blacklight_config.facet_fields['stanford_work_facet_hsim'].tap do |facet|
      facet.show = true
      facet.if = true
    end
  end

  def add_stanford_dept_facet
      return unless genre_facet_includes_thesis_value?

      blacklight_config.facet_fields['stanford_dept_sim'].tap do |facet|
        facet.show = true
        facet.if = true
      end
  end

  def genre_facet_includes_thesis_value?
    params[:f] &&
      params[:f][:genre_ssim] &&
      Array.wrap(params[:f][:genre_ssim]).any?('Thesis/Dissertation')
  end
end
