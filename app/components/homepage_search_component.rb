# frozen_string_literal: true

class HomepageSearchComponent < Blacklight::SearchBarComponent
  renders_one :footer

  def search_button
    render SearchButtonComponent.new(id: "#{@prefix}search", text: 'Search')
  end

  def advanced_search_enabled?
    false
  end

  def rounded_border_class
    ''
  end
end
