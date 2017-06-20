require "spec_helper"

describe "Searching within collections" do
  it "should return the zero results page when no items are present" do
    visit search_catalog_path( f: { collection: ['29'] } )

    fill_in 'q', with: 'abcde'
    click_button 'search'

    expect(page).to have_css('h2', text: 'No results found in catalog')
  end
end
