module RecordHelper
  def mods_display_label label
    content_tag(:dt, label.gsub(":",""))
  end

  def mods_display_content content
    content_tag(:dd, content.html_safe)
  end

  def mods_record_field field
    if field.respond_to?(:label, :values) &&
       field.values.any?(&:present?)
      mods_display_label(field.label) +
      mods_display_content(field.values.join)
    end
  end

  def mods_name_field(field)
    if field.respond_to?(:label, :values) &&
       field.values.any?(&:present?)
      mods_display_label(field.label) +
      mods_display_name(field.values)
    end
  end

  def mods_display_name(names)
    content_tag(:dd) do
      names.map do |name|
        "#{link_to(name.name, catalog_index_path(q: "\"#{name.name}\"", search_field: 'search_author'))}#{" (#{name.roles.join(', ')})" if name.roles.present?}"
      end.join('<br/>').html_safe
    end
  end
end
