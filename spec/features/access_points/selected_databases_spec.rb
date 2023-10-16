require 'rails_helper'

RSpec.feature "Selected Databases Access Point" do
  before do
    visit selected_databases_path
  end

  scenario "should have a custom masthead" do
    expect(page).to have_title("Databases in SearchWorks catalog")
    within("#masthead") do
      expect(page).to have_css("h1", text: "Selected article databases")
      expect(page).to have_css("a", text: "Articles+")
      expect(page).to have_css("a", text: "Databases")
      expect(page).to have_css("a", text: "Connecting to e-resources")
      expect(page).to have_css("a", text: "Report a connection problem")
    end
  end
  scenario "should have a custom breadcrumb" do
    within(".breadcrumb") do
      expect(page).to have_css("h2", text: /\d+ results/)
    end
  end
  scenario "has a panel with database info" do
    within(".selected-databases") do
      within(first('.card', text: '(General, Multidisciplinary)')) do
        expect(page).to have_css("h3 a", text: /Selected Database \d/)
        expect(page).to have_css("p", text: /\(.*\)/)
        expect(page).to have_css("dt", text: /Search database/)
        expect(page).to have_css('.stanford-only')
        expect(page).to have_css("a", text: /search.ebscohost.com/)
      end
    end
  end
end
