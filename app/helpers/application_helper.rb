module ApplicationHelper

  def render_search_bar_advanced_widget
    render partial:'catalog/search_bar_advanced_widget'
  end

  def render_search_bar_browse_widget
    render partial: 'catalog/search_bar_browse_widget'
  end

  def render_search_bar_selections_widget
    render partial: 'catalog/search_bar_selections_widget'
  end

  def render_search_targets_widget
    render partial: 'catalog/search_targets_widget'
  end

end
