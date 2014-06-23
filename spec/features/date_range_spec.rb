require "spec_helper"

feature "Date Range plugin" do
  scenario "Search results should have date slider facet", js: true do
    visit catalog_index_path f: {access_facet: ["Online"]}
    page.find('h5.panel-title', text: "Date").click
    expect(page).to have_css 'input.range_begin'
    expect(page).to have_css 'input.range_end'
  end
end
