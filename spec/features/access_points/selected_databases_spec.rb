require 'spec_helper'

feature "Selected Databases Access Point" do
  before do
    visit selected_databases_path
  end
  scenario "should have a custom masthead" do
    expect(page).to have_title("Selected databases in SearchWorks")
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
        expect(page).to have_css("a.header", text: /Search database \(\d+\)/)
        expect(page).to have_css("a", text: /\.stanford\.edu/)
      end
    end
  end
end
