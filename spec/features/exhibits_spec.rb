# frozen_string_literal: true

require 'rails_helper'

feature 'Exhibits', js: true do
  let(:results) do
    10.times.map do |i|
      AbstractSearchService::Result.new.tap do |result|
        result.title = "Exhibit title #{i}"
        result.link = "https://www.example.com/#{i}"
        result.description = "The description for Exhibit #{i}"
      end
    end
  end

  before do
    response = instance_double(
      AbstractSearchService::Response,
      results: results,
      total: results.length,
      highlighted_facet_values: [],
      additional_facet_details: nil
    )
    allow_any_instance_of(AbstractSearchService).to receive(:search)
      .and_return response
    visit quick_search_path
  end

  scenario 'is present on index page' do
    fill_in 'params-q', with: 'Photography'
    click_button 'Search'

    within('#exhibits') do
      expect(page).to have_css('ol li', count: 10, visible: :all)
      expect(page).to have_css('ol li', count: 5, visible: :visible)
      expect(page).to have_css('ol li', count: 5, visible: :hidden)

      click_button 'Show 10 exhibits'
      expect(page).to have_css('ol li', count: 10, visible: :visible)
      expect(page).to have_css('ol li', count: 0, visible: :hidden)

      click_button 'Show fewer'
      expect(page).to have_css('ol li', count: 10, visible: :all)
      expect(page).to have_css('ol li', count: 5, visible: :visible)
      expect(page).to have_css('ol li', count: 5, visible: :hidden)

      expect(page).to have_button('Show 10 exhibits')
      expect(page).not_to have_button('Show fewer')
    end
  end
end
