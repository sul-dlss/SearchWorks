module Searchworks::PaginationHelper

  def is_current_per_page?(count, label)
    if count == current_per_page
      content_tag(:span, '', class: 'glyphicon glyphicon-ok') + " " + label
    else
      label
    end
  end

  def is_current_sort?(field)
    label = field.label
    if field.field == current_sort
      content_tag(:span, '', class: 'glyphicon glyphicon-ok') + " " + label.to_s.titleize
    else
      label.to_s.titleize
    end
  end

  def current_sort
    params.fetch(:sort, default_sort_field)
  end

end
