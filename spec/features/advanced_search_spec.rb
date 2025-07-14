# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Advanced Search" do
  before do
    visit advanced_search_path
  end

  scenario "has correct fields and headings", :js do
    expect(page).to have_title("Advanced search in SearchWorks catalog")
    expect(page).to have_css("h2", text: "Search")
    expect(page).to have_css("h2", text: "Filters")

    expect(page).to have_css('.search-field', text: 'All fields', count: 1)

    find('.search-field').click
    expect(page).to have_css '[role="listbox"] li', text: "All fields"
    expect(page).to have_css '[role="listbox"] li', text: "Title"
    expect(page).to have_css '[role="listbox"] li', text: "Author"
    expect(page).to have_css '[role="listbox"] li', text: "Subject"
    expect(page).to have_css '[role="listbox"] li', text: "Call number"
    expect(page).to have_css '[role="listbox"] li', text: "Series"
    find('[role="listbox"] li:nth-child(2)').click
    expect(page).to have_css('.search-field', text: 'Title', count: 1)

    click_on 'Add search terms'
    expect(page).to have_css('.search-field', count: 2)

    expect(page).to have_css(".flex-row", text: "Access")
    expect(page).to have_css(".flex-row", text: "Date")
    expect(page).to have_css(".flex-row", text: "Format")
    expect(page).to have_css(".flex-row", text: "Language")

    expect(page).to have_button 'Add filter'
    click_on 'Add filter'
    click_on 'Library'
    expect(page).to have_css(".flex-row", text: "Library")

    expect(page).to have_button 'Search'
    expect(page).to have_button 'Reset'
  end

  it 'submits the form with the search parameters', :js do
    find('.search-field').click
    find('[role="listbox"] li:nth-child(2)').click
    fill_in 'Title search term', with: 'Image title'
    click_on 'Add search terms'
    fill_in 'All fields search term', with: 'Cats'

    page.driver.browser.execute_script("document.querySelector('form').submit()")
    expect(page).to have_css('.blacklight-catalog-index')
    uri = URI.parse(page.current_url)
    query = Rack::Utils.parse_nested_query(uri.query).with_indifferent_access

    expect(query['clause'].values).to include(
      { field: 'search_title', op: 'must', query: 'Image title' },
      { field: 'search', op: 'must', query: 'Cats' }
    )
  end

  it 'submits the form with the filter parameters', :js do
    find_field('Access').send_keys 'Onl'
    find('[role="listbox"] li:nth-child(2)').click
    page.driver.browser.execute_script("document.querySelector('form').submit()")
    expect(page).to have_css('.blacklight-catalog-index')
    uri = URI.parse(page.current_url)
    query = Rack::Utils.parse_nested_query(uri.query).with_indifferent_access

    expect(query).to include(
      'f' => {
        'access_facet' => ['Online']
      }
    )
  end

  scenario "should have search tips" do
    pending 'Search tips need to be reviewed + rewritten'

    within ".advanced-search-form" do
      expect(page).to have_css("h2", text: "Search tips")
      expect(page).to have_css("ul.advanced-help")
    end
  end
end
