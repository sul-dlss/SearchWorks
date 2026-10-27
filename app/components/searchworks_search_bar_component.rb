# frozen_string_literal: true

class SearchworksSearchBarComponent < Blacklight::SearchBarComponent
  delegate :controller_name, to: :helpers
end
