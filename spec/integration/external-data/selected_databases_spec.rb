require 'spec_helper'

feature "Selected Databases Access Point", :"data-integration" => true do
  before do
    visit selected_databases_path
  end

  scenario "should have a custom masthead" do
    within("#masthead") do
      expect(page).to have_css("h1", text: "Selected article databases")
      expect(page).to have_css("a", text: "All databases")
      expect(page).to have_css("a", text: "Connect from off campus")
      expect(page).to have_css("a", text: "Report a connection problem")
    end
  end
  scenario "should have a custom breadcrumb" do
    within(".breadcrumb") do
      expect(page).to have_css("h2", text: "13 results")
    end
  end
  scenario "titles" do
    within(".selected-databases") do
      within(first(".panel")) do
        expect(page).to have_css("h3 a", text: "Academic search premier")
      end
    end
  end
  scenario "subjects" do
    within(".selected-databases") do
      within(first(".panel")) do
        expect(page).to have_css("span.subjects", text: "(General, Multidisciplinary)")
      end
    end
  end
  scenario "online link" do
    within(".selected-databases") do
      within(first(".panel")) do
        expect(page).to have_css("a.selected-database", text: "Search database")
        expect(page).to have_css("a", text: "search.ebscohost.com")
      end
    end
  end
  scenario "description" do
    within(".selected-databases") do
      within(first(".panel")) do
        expect(page).to have_content("Multidisciplinary database of over 4,650 mostly scholarly publications, many full-text; a great place to start your research.")
      end
    end
  end
  scenario 'see also' do
    within(".selected-databases") do
      expect(page).to have_content("(See also Art Retrospective)")
      expect(page).to have_css("a", text: "Art Retrospective")
    end
  end
  scenario "should be accessible from the home page" do
    visit root_path
    click_link "Selected article databases"
    expect(page).to have_css("h1", text: "Selected article databases")
  end
end
