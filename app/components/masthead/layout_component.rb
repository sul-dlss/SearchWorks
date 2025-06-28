# frozen_string_literal: true

module Masthead
  class LayoutComponent < ViewComponent::Base
    renders_one :header
    renders_one :search
    renders_one :aside
  end
end
