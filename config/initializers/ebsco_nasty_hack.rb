# frozen_string_literal: true

Rails.application.config.to_prepare do
  EBSCO::EDS::SearchCriteria.class_eval do
    alias_method :original_initialize, :initialize

    def initialize(options = {}, info)
      original_initialize(options, info)
      pub_year_tisim_range = '2025-04/2025-05'
      @Limiters.push({:Id => 'DT1', :Values => [pub_year_tisim_range]})
    end
  end
end
