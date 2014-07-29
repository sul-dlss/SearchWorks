module BlacklightUrlHelper
  include Blacklight::UrlHelperBehavior

  # Link to the previous document in the current search context
  def link_to_previous_document(previous_document)
    css_class = 'previous btn btn-sul-toolbar ' + (previous_document.nil? ? 'disabled' : '')
    link_opts = session_tracking_params(previous_document, search_session['counter'].to_i - 1).merge(:class => css_class, :rel => 'prev')

    link_to url_for_document(previous_document), link_opts do
      t('views.pagination_compact.previous').html_safe
    end
  end

  # Link to the next document in the current search context
  def link_to_next_document(next_document)
    css_class = 'next btn btn-sul-toolbar ' + (next_document.nil? ? 'disabled' : '')
    link_opts = session_tracking_params(next_document, search_session['counter'].to_i + 1).merge(:class => css_class, :rel => 'next')

    link_to url_for_document(next_document), link_opts do
      t('views.pagination_compact.next').html_safe
    end
  end

end
