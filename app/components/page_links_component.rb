# frozen_string_literal: true

class PageLinksComponent < ViewComponent::Base
  delegate :link_to_previous_page, :link_to_next_page, :page_entries_info, to: :helpers
  def initialize(response:)
    @response = response
    super()
  end
  attr_accessor :response
end
