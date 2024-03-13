# frozen_string_literal: true

module MarcHelper
  def render_if_present(renderable)
    render renderable if renderable.present?
  end

  def results_imprint_string(document)
    document.fetch(:imprint_display, []).first
  end

  def get_uniform_title(doc)
    return unless doc['uniform_title_display_struct']

    data = doc['uniform_title_display_struct'].first.with_indifferent_access
    field_data = data[:fields].first[:field]

    search_field = if %w(130 730).include?(data[:fields].first[:uniform_title_tag])
                     'search_title'
                   else
                     'author_title'
                   end
    vern = data[:fields].first[:vernacular][:vern]
    href = "\"#{[field_data[:author], field_data[:link_text]].join(' ')}\""
    {
      label: data[:label],
      unmatched_vernacular: data[:unmatched_vernacular],
      fields: [
        {
          field: "#{field_data[:pre_text]} #{link_to(field_data[:link_text],
                                                     { action: 'index', controller: 'catalog', q: href, search_field: })} #{field_data[:post_text]}".html_safe,
          vernacular: (link_to(vern, { q: "\"#{vern}\"", controller: 'catalog', action: 'index', search_field: }) if vern)
        }
      ]
    }
  end
end
