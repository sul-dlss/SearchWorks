require "spec_helper"

feature "Advanced Search" do
  before do
    visit blacklight_advanced_search_engine.advanced_search_path
  end

  scenario "should have correct fields and headings" do
    expect(page).to have_title("Advanced search in SearchWorks catalog")
    within ".advanced-search-form" do
      expect(page).to have_css("h1", text: "Advanced search")
      within ".query-criteria" do
        expect(page).to have_css("select#op")
        expect(page).to have_css("select#op option", text: "all")
        expect(page).to have_css("select#op option", text: "any")
        expect(page).to have_css("label.control-label", text: "All fields")
        expect(page).to have_css("input#search")
        expect(page).to have_css("label.control-label", text: "Title")
        expect(page).to have_css("input#search_title")
        expect(page).to have_css("label.control-label", text: "Author")
        expect(page).to have_css("input#search_author")
        expect(page).to have_css("label.control-label", text: "Subject")
        expect(page).to have_css("input#subject_terms")
        expect(page).to have_css("label.control-label", text: "Series title")
        expect(page).to have_css("input#series_search")
        expect(page).to have_css("label.control-label", text: "Place, publisher, year")
        expect(page).to have_css("input#pub_search")
        expect(page).to have_css("label.control-label", text: "ISBN/ISSN")
        expect(page).to have_css("input#isbn_search")
      end
      within ".limit-criteria" do
        expect(page).to have_css("h3.card-header a", text: "Access")
        expect(page).to have_css("label", text: "At the Library")
        expect(page).to have_css("input#f_inclusive_access_facet_at-the-library")
        expect(page).to have_css("h3.card-header a", text: "Resource type")
        expect(page).to have_css("label", text: "Book")
        expect(page).to have_css("input#f_inclusive_format_main_ssim_book")
        expect(page).to have_css("h3.card-header a", text: "Library")
        expect(page).to have_css("label", text: "Green")
        expect(page).to have_css("input#f_inclusive_building_facet_green")
        expect(page).to have_css("h3.card-header a", text: "Language")
        expect(page).to have_css("label", text: "Chinese")
        expect(page).to have_css("input#f_inclusive_language_chinese")
      end
      within ".sort-submit-buttons" do
        expect(page).to have_css("h2", text: "Sort results by")
        expect(page).to have_css("select#sort")
        expect(page).to have_css("button", text: "Search")
        expect(page).to have_css("button", text: "Clear form")
      end
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
      expect(page).to have_css("h3", text: "Search tips")
      expect(page).to have_css("ul.advanced-help")
    end
  end
end
