
module Searchworks4
  class InclusiveSelectedQfacetValueComponent < Blacklight::Hierarchy::SelectedQfacetValueComponent
    def initialize(values:, field_name:, item:)
      @values = values
      super(field_name:, item:)
    end

    def remove_href
      # Generate the new values for the remove link without the value for this item
      # @values is a nested array e.g. [['A', 'B']], but to add values back
      # we need a regular array, hence the flattening.
      new_values = @values.map { |v| v - [item.qvalue] }.flatten
      # Remove the old values and then add new values
      new_state = helpers.search_state.filter(field_name).remove(@values)
      new_state = new_state.filter(field_name).add(new_values)
      # Set the path with the parameters for the intended state
      helpers.search_action_path(new_state.params)
    end
  end
end