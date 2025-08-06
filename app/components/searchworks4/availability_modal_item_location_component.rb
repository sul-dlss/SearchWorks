# frozen_string_literal: true

module Searchworks4
  class AvailabilityModalItemLocationComponent < AccessPanels::LocationItemComponent
    def boundwith_principal_component
      @boundwith_principal_component ||= Searchworks4::Item::BoundWithPrincipalListComponent.new(item:, document:)
    end
  end
end
