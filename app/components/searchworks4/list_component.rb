# frozen_string_literal: true

module Searchworks4
  class ListComponent < Blacklight::Facets::ListComponent
    def facet_items(wrapping_element: :li, **item_args)
      puts "SW4 LIST COMPONENT FACET ITEMS"
      puts "FIC CLASS #{facet_item_component_class.inspect}"
      puts "Facet item presenters#{facet_item_presenters.inspect}"
      puts "Wrapping element #{wrapping_element.inspect}"
      facet_item_component_class.with_collection(facet_item_presenters, wrapping_element: wrapping_element, **item_args)
    end

    def inclusive_present?
      @facet_field.values.find { |v| v.is_a? Array }
    end
  end
end
