# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # @return [Integer]
  def sw_current_per_page(response)
    (response.rows if response && response.rows > 0) || # rubocop:disable Style/NumericPredicate
      params.fetch(:per_page, blacklight_config.default_per_page).to_i
  end

  ##
  # The available options for results per page, in the style of #options_for_select
  def sw_per_page_options_for_select
    return [] if blacklight_config.per_page.blank?

    blacklight_config.per_page.map do |count|
      [t(:'blacklight.search.per_page.label', count: count).html_safe, count]
    end
  end

  # Find a display label for the library code facet. We no longer want the display label in the index, because this prevents us
  # from changing the label without a full reindex.
  # This displays the label from libraries.json
  def translate_library_code(solr_value)
    return 'Stanford Digital Repository' if solr_value == 'SDR'
    return 'Off-campus collections' if solr_value == 'OFF_CAMPUS'

    library = Folio::Types.libraries.values.find { it['code'] == solr_value }
    return solr_value unless library

    folio_name = library.fetch('name')
    # We strip 'Library' from the name because it appears in a facet called 'Library'.. except Hoover
    return folio_name if folio_name.include?('Hoover')

    folio_name.sub(' Library', '')
  end
end
