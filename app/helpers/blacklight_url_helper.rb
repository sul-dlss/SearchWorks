module BlacklightUrlHelper
  include Blacklight::UrlHelperBehavior

  # Override from Blacklight::UrlHelperBehavior to provide custom class
  def link_to_previous_document(previous_document)
    link_opts = session_tracking_params(previous_document, search_session['counter'].to_i - 1).merge(class: 'previous btn btn-sul-toolbar ', rel: 'prev')
    link_to_unless previous_document.nil?, raw(t('views.pagination_compact.previous')), search_state.url_for_document(previous_document), link_opts do
      content_tag :span, raw(t('views.pagination_compact.previous')), class: 'previous'
    end
  end

  # Override from Blacklight::UrlHelperBehavior to provide custom class
  def link_to_next_document(next_document)
    link_opts = session_tracking_params(next_document, search_session['counter'].to_i + 1).merge(class: 'next btn btn-sul-toolbar ', rel: 'next')
    link_to_unless next_document.nil?, raw(t('views.pagination_compact.next')), search_state.url_for_document(next_document), link_opts do
      content_tag :span, raw(t('views.pagination_compact.next')), class: 'next'
    end
  end
end
