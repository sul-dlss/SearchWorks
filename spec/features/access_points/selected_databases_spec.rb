require 'spec_helper'

feature "Selected Databases Access Point" do
  before do
    visit selected_databases_path
  end
  scenario "should have a custom masthead" do
    within("#masthead") do
      expect(page).to have_css("h1", text: "Selected Databases")
      expect(page).to have_css("a", text: "All databases")
      expect(page).to have_css("a", text: "Connect from off campus")
      expect(page).to have_css("a", text: "Report a connection problem")
    end
  end
  scenario "should have a custom breadcrumb" do
    within(".breadcrumb") do
      expect(page).to have_css("h2", text: /\d+ results/)
    end
  end
  scenario "should have a panel with database info" do
    within(".selected-databases") do
      within(first(".panel")) do
        expect(page).to have_css("h3 a", text: /Selected Database \d/)
        expect(page).to have_css("span.subjects", text: /\(.*\)/)
        expect(page).to have_css("span.label.label-success", text: "Search database")
        expect(page).to have_css("a", text: /\.stanford\.edu/)
      end
    end
  end
end
