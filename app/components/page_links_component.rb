# frozen_string_literal: true

class PageLinksComponent < ViewComponent::Base
  def initialize(response:)
    @response = response
    super()
  end
  attr_accessor :response
end
