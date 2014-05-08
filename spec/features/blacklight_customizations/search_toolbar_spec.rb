require "spec_helper"

describe "Search toolbar", js: true, feature: true do
    before { visit root_path }
  describe "has SearchWorks customizations" do
    it "should display correct elements" do
      within "#search-navbar" do
        expect(page.find('button.btn.btn-primary.search-btn')).to have_no_content 'Search'
        expect(page).to have_css("li.disabled a", text: "Advanced", visible: true)
        expect(page).to have_css("li.disabled a", text: "Browse", visible: true)
        expect(page).to have_css("li.disabled a", text: "Selections", visible: true)
      end
    end
  end
end
