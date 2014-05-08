module MastheadHelper
  def render_masthead_partial
    if page_location.access_point?
      begin
        render "catalog/mastheads/#{page_location.access_point}"
      rescue ActionView::MissingTemplate
      end
    end
  end
  def facets_prefix_options
    ["0-9", ("A".."Z").to_a.delete_if{|letter| letter == "X"}].flatten
  end
end
