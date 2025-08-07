# frozen_string_literal: true

module Searchworks4
  class InclusiveQfacetValueComponent < Blacklight::Hierarchy::QfacetValueComponent
    def initialize(values:, field_name:, item:, id: nil, suppress_link: false)
      @values = values
      super(field_name:, item:, id:, suppress_link:)
    end

    def path_for_facet
      new_values = @values.map { |v| v + [item.qvalue] }.flatten
      # Remove the old values and then add new values which have the facet value for the link added
      new_state = helpers.search_state.filter(field_name).remove(@values)
      new_state = new_state.filter(field_name).add(new_values)

      # Set the path with the parameters for the intended state
      helpers.search_action_path(new_state.params)
    end
  end
end
