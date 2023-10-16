# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Date Range', :js do
  scenario 'Search results should have date slider facet' do
    visit search_catalog_path f: { access_facet: ['Online'] }
    click_button 'Date'
    expect(page).to have_css 'input.range_begin'
    expect(page).to have_css 'input.range_end'
    expect(page).to have_xpath '//input[@value="Apply"]'
  end

  scenario 'Article date range' do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
    visit articles_path f: { eds_search_limiters_facet: ['Stanford has it'] }
    click_button 'Date'
    within '.blacklight-pub_year_tisim' do
      expect(page).to have_field 'range[pub_year_tisim][begin]', with: 1501
      expect(page).to have_field 'range[pub_year_tisim][end]', with: 2018
      fill_in 'range_pub_year_tisim_begin', with: 1900
      click_button 'Apply'
    end

    within '.blacklight-pub_year_tisim' do
      expect(page).to have_field 'range[pub_year_tisim][begin]', with: 1900, visible: true
    end
  end
end
