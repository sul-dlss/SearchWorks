# frozen_string_literal: true

class MastheadSearchComponent < Blacklight::SearchBarComponent
  # rubocop:disable Metrics/ParameterLists, Naming/MethodParameterName
  def initialize(
    url:,
    params:,
    advanced_search_url: nil,
    classes: %w[search-query-form col-md-12 col-lg-8], prefix: nil,
    method: 'GET', q: nil, query_param: :q,
    search_field: nil, autocomplete_path: nil,
    autofocus: nil, i18n: { scope: 'blacklight.search.form' },
    form_options: {}
  )
    super
    # Omit view to avoid being stuck in gallery mode from book funds/full page browse nearby.
    @params = @params.except(:view)
  end
  # rubocop:enable Metrics/ParameterLists, Naming/MethodParameterName

  def search_button
    render SearchButtonComponent.new(id: "#{@prefix}search", text: 'Search')
  end

  def advanced_search_enabled?
    false
  end

  def rounded_border_class
    ''
  end
end
