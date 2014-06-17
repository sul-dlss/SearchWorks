module PreviewHelper

  def preview_data_attrs(show_preview = true, preview_type, id, target)
    if show_preview
      attrs = "data-behavior=\"#{preview_type}\" data-preview-url=\"#{preview_path(id)}\" data-preview-target=\"#{target}\""
    end

    (attrs ||= '').html_safe
  end

end