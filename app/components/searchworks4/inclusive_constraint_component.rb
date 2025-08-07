# frozen_string_literal: true

module Searchworks4
  class InclusiveConstraintComponent < Blacklight::Facets::InclusiveConstraintComponent
    # The original inclusive component ONLY renders the values that were passed
    # in as inclusive. We want to change this to be all values
    def values
      @values ||= @facet_field.values.find { |v| v.is_a? Array }
      @values || []
    end

    def facet_values
      @facet_field.values
    end


    def facet_item_presenters
      @facet_field.paginator.items.map do |item|
        Blacklight::FacetItemPresenter.new(item, @facet_field.facet_field, helpers, @facet_field.key)
      end
    end

    def presenters
      return to_enum(:presenters) unless block_given?

      # We will display ALL values
      facet_values.each do |item|
        if item.is_a? Array
          item.each do|item_value|
            # yield Blacklight::FacetGroupedItemPresenter.new(item, item_value, @facet_field.facet_field, helpers, @facet_field.key, @facet_field.search_state)
            yield Blacklight::FacetItemPresenter.new(item_value, @facet_field.facet_field, helpers, @facet_field.key)
          end
        else
          puts "ICC NOT ARRAY #{item.inspect}"
          yield Blacklight::FacetItemPresenter.new(item, @facet_field.facet_field, helpers, @facet_field.key)
        end
        #yield Blacklight::FacetGroupedItemPresenter.new(values, item, @facet_field.facet_field, helpers, @facet_field.key, @facet_field.search_state)
      end
    end
  
  
  end
end
