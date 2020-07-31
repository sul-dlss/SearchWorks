# frozen_string_literal: true

require 'rails_helper'

feature 'LibGuides', js: true do
  before do
    response = instance_double(AbstractSearchService::Response, results: [], total: 0)
    allow_any_instance_of(AbstractSearchService).to receive(:search)
      .and_return response
    visit quick_search_path
  end

  scenario 'is present on index page' do
    fill_in 'params-q', with: 'geology'
    click_button 'Search'
    expect(page).to have_css 'h2', text: 'Guides'
    page.save_and_open_screenshot
  end
end
