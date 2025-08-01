# frozen_string_literal: true

module WithPageLocation
  extend ActiveSupport::Concern

  def page_location
    @page_location ||= PageLocation.new(search_state)
  end
  included do
    helper_method :page_location
  end
end
