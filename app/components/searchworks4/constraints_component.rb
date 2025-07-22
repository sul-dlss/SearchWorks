# frozen_string_literal: true

# Overriding the Blacklight component to move the start over button
module Searchworks4
  class ConstraintsComponent < Blacklight::ConstraintsComponent
    def initialize(start_over_component: Searchworks4::StartOverButtonComponent,
                   query_constraint_component: Searchworks4::ConstraintLayoutComponent,
                   facet_constraint_component: Searchworks4::ConstraintComponent,
                   facet_constraint_component_options: { layout: Searchworks4::ConstraintLayoutComponent },
                   **args)
      super
      @classes += ' gap-2 mt-3'
    end

    # In the situation of advanced search, we want to use our own clause presenters
    # We still want to accept the query constraints the super method uses as well
    def query_constraints
      if @search_state.query_param.present?
        render(
          @query_constraint_component.new(
            search_state: @search_state,
            value: @search_state.query_param,
            label: label,
            remove_path: remove_path,
            classes: 'query',
            **@query_constraint_component_options
          )
        )
      else
        ''.html_safe
      end +  render(@facet_constraint_component.with_collection(advanced_clause_presenters.to_a, **@facet_constraint_component_options))
    end

    # Extending the core method to allow using custom inclusive and negative facet item presenters
    # to handle the display of prefixes for advanced search results
    def facet_item_presenters
      return to_enum(:facet_item_presenters) unless block_given?

      @search_state.filters.map do |facet|
        facet.each_value do |val|
          next if val.blank?

          if val.is_a?(Array)
            yield inclusive_facet_item_presenter(facet.config, val, facet.key) if val.any?(&:present?)
          elsif negative_facet?(facet.config)
            yield negative_facet_item_presenter(facet.config, val, facet.key)
          else
            yield facet_item_presenter(facet.config, val, facet.key)
          end
        end
      end
    end

    private

    # This method returns the presenter for advanced search clauses
    def advanced_clause_presenters
      return to_enum(:advanced_clause_presenters) unless block_given?

      @search_state.clause_params.each do |key, clause|
        field_config = helpers.blacklight_config.search_fields[clause[:field]]
        yield AdvancedClausePresenter.new(key, clause, field_config, helpers)
      end
    end

    # This method returns an extension of the inclusive facet item presenter
    # that enables the prefix method
    def inclusive_facet_item_presenter(facet_config, facet_item, facet_field)
      Searchworks4::InclusiveFacetItemPresenter.new(facet_item, facet_config, helpers, facet_field)
    end

    # This method returns an extension of the Negative Facet Item Presenter
    # that implements a prefix method
    def negative_facet_item_presenter(facet_config, facet_item, facet_field)
      Searchworks4::NegativeFacetItemPresenter.new(facet_item, facet_config, helpers, facet_field)
    end

    # Is this a negative facet situation e.g. Language != English?
    def negative_facet?(facet_config)
      facet_config.group == 'negative'
    end
  end
end
