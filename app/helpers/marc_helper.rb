# frozen_string_literal: true

module MarcHelper
  def render_if_present(renderable)
    render renderable if renderable.present?
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

    {
      label: data[:label],
      unmatched_vernacular: format_uniform_title_value(data[:unmatched_vernacular], search_field:),
      fields: [
        {
          field: format_uniform_title_value(field_data, search_field:),
          vernacular: format_uniform_title_value(vern, search_field:)
        }
      ]
    }
  end

  def format_uniform_title_value(field_data, search_field:)
    return unless field_data

    return link_to(field_data, { q: "\"#{field_data}\"", controller: 'catalog', action: 'index', search_field: }) if field_data.is_a?(String)

    q = "\"#{[field_data[:author], field_data[:link_text]].join(' ')}\""
    link = link_to(field_data[:link_text], { action: 'index', controller: 'catalog', q:, search_field: })

    safe_join([field_data[:pre_text], link, field_data[:post_text]].compact, " ")
  end
end
