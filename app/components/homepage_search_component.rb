# frozen_string_literal: true

class HomepageSearchComponent < Blacklight::SearchBarComponent
  def search_button
    render SearchButtonComponent.new(id: "#{@prefix}search", text: 'Search')
  end

  def advanced_search_enabled?
    false
  end
end
