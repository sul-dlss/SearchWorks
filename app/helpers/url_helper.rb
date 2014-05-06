module UrlHelper

  ##
  # Link to the previous document in the current search context
  def link_to_previous_doc(previous_document)
    link_opts = session_tracking_params(previous_document, search_session['counter'].to_i - 1).merge(:class => 'previous btn btn-default', :rel => 'prev')

    unless previous_document.nil?
      link_to url_for_document(previous_document), link_opts do
        content_tag :span, '', :class => 'previous glyphicon glyphicon-chevron-left'
      end
    end
  end

  ##
  # Link to the next document in the current search context
  def link_to_next_doc(next_document)
    link_opts = session_tracking_params(next_document, search_session['counter'].to_i + 1).merge(:class => 'next btn btn-default', :rel => 'next')

    unless next_document.nil?
      link_to url_for_document(next_document), link_opts do
        content_tag :span, '', :class => 'next glyphicon glyphicon-chevron-right'
      end
    end
  end


end