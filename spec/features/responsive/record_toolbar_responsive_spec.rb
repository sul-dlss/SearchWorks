require "spec_helper"

# TODO revisit on individual viewports, visible: true/false functionality not working correctly
describe "Record toolbar", js: true, feature: true do
  before do
    visit('/view/1')
  end

  describe " - tablet view (768px - 980px) - " do
    it "should display correct toolbar items" do
      pending("tablet view responsive behavior for record toolbar")
    end
  end

  describe " - mobile landscape view (480px - 767px) - " do
    it "should display correct toolbar items" do
      pending("mobile view responsive behavior for record toolbar")
    end
  end

end