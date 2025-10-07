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

    expect(page).to have_css('.search-field', text: 'All fields', count: 2)

    find_all('.search-field').first.click
    expect(page).to have_css '[role="listbox"] li', text: "All fields"
    expect(page).to have_css '[role="listbox"] li', text: "Title"
    expect(page).to have_css '[role="listbox"] li', text: "Author"
    expect(page).to have_css '[role="listbox"] li', text: "Subject"
    expect(page).to have_css '[role="listbox"] li', text: "Call number"
    expect(page).to have_css '[role="listbox"] li', text: "Series"
    find('[role="listbox"] li:nth-child(2)').click
    expect(page).to have_css('.search-field', text: 'Title', count: 1)

    click_on 'Add search terms'
    expect(page).to have_css('.search-field', count: 3)

    expect(page).to have_css(".flex-row", text: "Access")
    expect(page).to have_css(".flex-row", text: "Publication year")
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
    find_all('.search-field').first.click
    find('[role="listbox"] li:nth-child(2)').click
    fill_in 'Title search term', with: 'Image title'
    fill_in 'All fields search term', with: 'Cats'

    page.driver.browser.execute_script("document.querySelector('form').submit()")
    expect(page).to have_css('.blacklight-catalog-index')
    uri = URI.parse(page.current_url)
    query = Rack::Utils.parse_nested_query(uri.query).with_indifferent_access

    expect(query['clause'].values).to include(
      { field: 'search_title', type: 'all', query: 'Image title' },
      { field: 'search', type: 'all', query: 'Cats' }
    )
  end

  it 'submits the form with the filter parameters', :js do
    find_field('Access').send_keys 'Onl'
    find('[role="listbox"] li', text: 'Online').click
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

  it 'gets the expected results for an advanced search query with contains any', :js do
    # Switch the first field to "Title"
    find_all('.search-field').first.click
    find('[role="listbox"] li:nth-child(2)').click

    # Switch the operator to "contains any"
    find_all('.search-operator').first.click
    find('[role="listbox"] li:nth-child(2)').click

    fill_in 'Title search term', with: 'portal topics'

    page.driver.browser.execute_script("document.querySelector('form').submit()")
    expect(page).to have_css('.blacklight-catalog-index')
    uri = URI.parse(page.current_url)
    query = Rack::Utils.parse_nested_query(uri.query).with_indifferent_access

    expect(query['clause'].values).to include(
      { field: 'search_title', type: 'any', query: 'portal topics' }
    )

    expect(page).to have_content('Arctic science portal').and have_content('Aristotle : topics')
  end

  scenario "should have search tips" do
    within ".advanced-search-form" do
      expect(page).to have_css("h2", text: "Tips for better results")
    end
  end
end
