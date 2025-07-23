# frozen_string_literal: true

module AccessibilityHelpers
  # An alias so our tests are less coupled to the aXe implementation
  def be_accessible(...)
    standards = [:'best-practice', :wcag2a, :wcag2aa, :wcag21a, :wcag21aa]

    # Skip color contrast checks for '.disabled'
    # See https://github.com/sul-dlss/SearchWorks/issues/5359
    be_axe_clean(...).excluding('.disabled').according_to(standards)
    be_axe_clean(...).according_to(standards).skipping('color-contrast')
  end
end

RSpec.configure do |config|
  config.include AccessibilityHelpers, type: :feature
end
