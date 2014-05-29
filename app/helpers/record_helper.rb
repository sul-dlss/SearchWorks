module RecordHelper
  def mods_display_label(label)
    content_tag(:dt, label.gsub(":",""))
  end

  def mods_display_content(content)
    content_tag(:dd, content.html_safe)
  end

  def mods_record_field(field, section_type)
    if field.respond_to?(:label, :values)
      content_tag(:div, class:"section-#{section_type}") do
        mods_display_label(field.label) +
        mods_display_content(field.values.join)
      end
    end
  end

end
