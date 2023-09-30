require "spec_helper"

RSpec.feature "Advanced Search" do
  before do
    visit blacklight_advanced_search_engine.advanced_search_path
  end

  scenario "has correct fields and headings" do
    expect(page).to have_title("Advanced search in SearchWorks catalog")
    within ".advanced-search-form" do
      expect(page).to have_css("h1", text: "Advanced search")
      within ".query-criteria" do
        expect(page).to have_css("select#op")
        expect(page).to have_css("select#op option", text: "all")
        expect(page).to have_css("select#op option", text: "any")
        expect(page).to have_field 'All fields'
        expect(page).to have_field 'Title'
        expect(page).to have_field 'Author'
        expect(page).to have_field 'Subject'
        expect(page).to have_field 'Series title'
        expect(page).to have_field 'Place, publisher, year'
        expect(page).to have_field 'ISBN/ISSN'
      end
      within ".limit-criteria" do
        expect(page).to have_css("h3.facet-field-heading button", text: "Access")
        expect(page).to have_field 'At the Library'
        expect(page).to have_css("h3.facet-field-heading button", text: "Resource type")
        expect(page).to have_field 'Book'
        expect(page).to have_css("h3.facet-field-heading button", text: "Library")
        expect(page).to have_field 'Green'
        expect(page).to have_css("h3.facet-field-heading button", text: "Language")
        expect(page).to have_field 'Chinese'
      end

      expect(page).to have_css("h2", text: "Sort results by")
      expect(page).to have_css("select#sort")

      expect(page).to have_button 'Search'
      expect(page).to have_button 'Clear form'
    end
  end
  scenario "simple search should work normally" do
    fill_in 'q', with: "A search"
    click_button 'search'

    within('.breadcrumb') do
      expect(page).to have_content("A search")
    end
  end
  scenario "should have search tips" do
    within ".advanced-search-form" do
      expect(page).to have_css("h2", text: "Search tips")
      expect(page).to have_css("ul.advanced-help")
    end
  end
end
