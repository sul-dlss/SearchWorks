# frozen_string_literal: true

require 'axe-rspec'

module AccessibilityHelpers
  # An alias so our tests are less coupled to the aXe implementation
  def be_accessible(...)
    be_axe_clean(...).according_to(
      :'best-practice',
      :wcag2a,
      :wcag2aa,
      :wcag21a,
      :wcag21aa
    )
  end
end

RSpec.configure do |config|
  config.include AccessibilityHelpers, type: :feature
end
