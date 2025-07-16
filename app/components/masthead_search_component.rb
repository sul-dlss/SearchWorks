# frozen_string_literal: true

class MastheadSearchComponent < Blacklight::SearchBarComponent
  def initialize(**)
    super
    # Omit view to avoid being stuck in gallery mode from book funds/full page browse nearby.
    @params = @params.except(:view)
  end

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
