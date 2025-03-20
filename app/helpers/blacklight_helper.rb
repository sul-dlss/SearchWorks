# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # @return [Integer]
  def sw_current_per_page
    (@response.rows if @response && @response.rows > 0) || # rubocop:disable Style/NumericPredicate
      params.fetch(:per_page, @blacklight_config.default_per_page).to_i
  end

  ##
  # The available options for results per page, in the style of #options_for_select
  def sw_per_page_options_for_select
    return [] if @blacklight_config.per_page.blank?

    @blacklight_config.per_page.map do |count|
      [t(:'blacklight.search.per_page.label', count: count).html_safe, count]
    end
  end
end
