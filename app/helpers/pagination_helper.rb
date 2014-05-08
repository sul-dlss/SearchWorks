module PaginationHelper

  def label_current_per_page(count, label)
    if count == current_per_page
      content_tag(:span, '', class: 'glyphicon glyphicon-ok') + " " + label
    else
      label
    end
  end

  def label_current_sort(field)
    label = field.label
    if field.field == current_sort_field.field
      content_tag(:span, '', class: 'glyphicon glyphicon-ok') + " " + label.to_s.titleize
    else
      label.to_s.titleize
    end
  end

end
