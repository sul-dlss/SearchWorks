require 'spec_helper'

feature "Selected Databases Access Point" do
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
  scenario "should have a panel with database info" do
    within(".selected-databases") do
      within(first('.panel', text: '(General, Multidisciplinary)')) do
        expect(page).to have_css("h3 a", text: /Selected Database \d/)
        expect(page).to have_css("span.subjects", text: /\(.*\)/)
        expect(page).to have_css("a.header", text: /Search database \(\d+\)/)
        expect(page).to have_css("a", text: /\.stanford\.edu/)
      end
    end
  end
  scenario 'accordion should reveal more information when clicked', js: true do
    within '.selected-databases' do
      within page.find('.panel', text: '(General, Multidisciplinary)') do
        expect(page).to have_css 'a.header span.section-label', text: 'Search database (2)'
        expect(page).to_not have_css 'a', text: 'searchworks.stanford.edu'
        page.find('span.section-label').click
        expect(page).to have_css 'a', text: 'searchworks.stanford.edu'
      end
    end
  end
end
