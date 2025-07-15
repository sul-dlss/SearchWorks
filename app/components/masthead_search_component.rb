# frozen_string_literal: true

class MastheadSearchComponent < Blacklight::SearchBarComponent
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
