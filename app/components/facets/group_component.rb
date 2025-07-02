# frozen_string_literal: true

module Facets
  class GroupComponent < Blacklight::Response::FacetGroupComponent
    attr_reader :expandable_filter_group

    def initialize(container_classes: 'facets sidenav mb-md-4', expandable_filter_group: false, offcanvas: false, **)
      @expandable_filter_group = expandable_filter_group
      @offcanvas = offcanvas

      super(container_classes: container_classes, **)
    end

    def expandable_in_sidebar?
      # All facet groups are expanded by default in the offcanvas placement area
      expandable_filter_group && !@offcanvas
    end

    def component_data
      # If we need the expand functionality, connect to the stimulus controller
      expandable_in_sidebar? ? { controller: 'facet-group' } : {}
    end

    def title_data
      expandable_in_sidebar? ? { facet_group_target: 'title' } : {}
    end

    # def title_classes
    #   classes = ['facet-group-title']
    #   case
    #   when @offcanvas
    #     classes << 'd-block'
    #   when expandable_in_sidebar?
    #     classes << 'd-none'
    #   when !@offcanvas && !expandable_filter_group
    #     classes << 'd-none d-lg-block'
    #   end

    #   classes.join(' ')
    # end

    def title_classes
      classes = ['facet-group-title']

      classes << if @offcanvas
                   # In offcanvas, show always
                   'd-block'
                 elsif expandable_in_sidebar?
                   # In sidebar and expandable: hidden by default (Stimulus toggles it)
                   'd-none'
                 else
                   # In sidebar and NOT expandable (Top filters): show from md and up
                   'd-none d-md-block'
                 end

      classes.join(' ')
    end

    def render_expand_button
      return unless expandable_in_sidebar?

      content_tag :div, class: "text-center mt-2" do
        button_tag class: "btn btn-primary",
                   data: {
                     'facet-group-target': "button",
                     action: "facet-group#toggle"
                   },
                   aria: {
                     controls: "hidden-facets",
                     expanded: "false"
                   } do
          safe_join([
            content_tag(:i, "", class: "bi bi-sliders", aria: { hidden: true }),
            " Show all filters"
          ])
        end
      end
    end
  end
end
