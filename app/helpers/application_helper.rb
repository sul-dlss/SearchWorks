# frozen_string_literal: true

module ApplicationHelper
  def from_advanced_search?
    params[:search_field] == 'advanced' || params[:clause].present?
  end

  # The Honeybadger notice filters, for inlining right after Honeybadger is configured. They are inlined
  # rather than loaded from a script tag so they are registered before any other script can fail to load or parse.
  def honeybadger_filters_script
    Rails.application.assets.load_path.find('honeybadger-filters.js').content
         .sub(%r{^//# sourceMappingURL=.*$}, '')
  end
end
