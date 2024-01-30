module PreviewHelper
  def preview_data_attrs(preview_type, id, target)
    "data-behavior=\"#{preview_type}\" data-preview-url=\"#{preview_path(id)}\" data-preview-target=\"#{target}\"".html_safe
  end
end
