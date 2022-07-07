class SearchworksSearchBarComponent < Blacklight::SearchBarComponent
  def controller_name
    helpers.controller_name
  end
end
