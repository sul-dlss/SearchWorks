# frozen_string_literal: true

class SearchworksSearchBarComponent < Blacklight::SearchBarComponent
  def controller_name
    helpers.controller_name
  end
end
