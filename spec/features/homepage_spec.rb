# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Homepage' do
  before do
    visit quick_search_path
  end

  scenario 'has top level headings for search tools and other sources' do
    expect(page).to have_css 'h3', text: 'Stanford University Libraries\' search tools'
    expect(page).to have_css 'h3', text: 'Other sources searched'
  end

  scenario 'has text for search tools headings' do
    expect(page).to have_css '.bento-heading', text: 'SearchWorks', count: 2
    expect(page).to have_css '.fw-bold', text: 'Catalog'
    expect(page).to have_css '.fw-bold', text: 'Articles'
    expect(page).to have_css 'div.fw-bold', text: 'Archival Collections at Stanford'
    expect(page).to have_css 'div.fw-bold', text: 'EarthWorks'
    expect(page).to have_css 'div.fw-bold', text: 'Spotlight Exhibits'
  end

  scenario 'has text for other sources searched' do
    expect(page).to have_css 'div.fw-bold', text: 'Library website'
    expect(page).to have_css 'div.fw-bold', text: 'Guides'
    expect(page).to have_css 'div.fw-bold', text: 'Subject specialists'
  end
end
