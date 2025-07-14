# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Date Range', :js do
  scenario 'Article date range' do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    visit articles_path q: 'some query', f: { eds_search_limiters_facet: ['Stanford has it'] }
    click_button 'Date'
    within '.blacklight-pub_year_tisim' do
      expect(page).to have_field 'range[pub_year_tisim][begin]', with: 1501
      expect(page).to have_field 'range[pub_year_tisim][end]', with: Time.zone.now.year + 1
      fill_in 'range_pub_year_tisim_begin', with: 1900
      click_button 'Apply'
    end

    within '.blacklight-pub_year_tisim' do
      expect(page).to have_field 'range[pub_year_tisim][begin]', with: 1900, visible: true
    end
  end
end
