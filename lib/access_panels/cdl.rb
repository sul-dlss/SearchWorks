# frozen_string_literal: true

class AccessPanels
  class Cdl < ::AccessPanel
    delegate :druid, to: :@document

    def present?
      druid && @document.holdings.callnumbers.any? { |call| call.home_location == 'CDL' }
    end
  end
end
