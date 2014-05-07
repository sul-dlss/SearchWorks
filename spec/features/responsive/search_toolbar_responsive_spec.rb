require "spec_helper"

# TODO revisit on individual viewports, visible: true/false functionality not working correctly
describe "Responsive search bar", js: true, feature: true do
  before do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'
  end
  describe " - tablet view (768px - 980px) - " do
    it "should display correct tools" do
      pending("tablet view responsive behavior for results toolbar")
    end
  end
  describe " - mobile landscape view (480px - 767px) - " do
    it "should display correct tools" do
      pending("mobile view responsive behavior for results toolbar")
    end
  end
end
