module PreviewHelper

  def preview_data_attrs(show_preview = true, id, target)
    if show_preview
      attrs = "data-behavior=\"preview\" data-preview-url=\"#{preview_path(id)}\" data-preview-target=\"#{target}\""
    end

    (attrs ||= '').html_safe
  end

end