# frozen_string_literal: true

module Searchworks4
  class ThesesDissertationFacetHeaderComponent < ViewComponent::Base
    attr_reader :selected, :checked_url, :unchecked_url

    def initialize(params:)
      @params = params

      @selected = stanford_only_selected?
      @checked_url = "/?f[genre_ssim][]=Thesis/Dissertation&f[stanford_work_facet_hsim][]=Thesis/Dissertation"
      @unchecked_url = "/?f[genre_ssim][]=Thesis/Dissertation"
      super
    end

    private

    def stanford_only_selected?
      genre = @params.dig(:f, :genre_ssim)
      work = @params.dig(:f, :stanford_work_facet_hsim)
      genre&.include?("Thesis/Dissertation") && work&.include?("Thesis/Dissertation")
    end
  end
end
