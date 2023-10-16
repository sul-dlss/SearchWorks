# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fielded Search' do
  before do
    visit root_url
    fill_in 'q', with: query
    select search_field, from: 'search_field'
    click_button 'search'
  end

  context 'title search' do
    let(:query) { 'An object' }
    let(:search_field) { 'Title' }

    it 'works' do
      expect(page).to have_css('.document', count: 1)
      expect(page).to have_css('.document h3.index_title a', text: 'An object')
    end
  end

  context 'author search' do
    let(:query) { 'Doe, Jane' }
    let(:search_field) { 'Author/Contributor' }

    it 'works' do
      expect(page).to have_css('.document', count: 1)
      expect(page).to have_css('.document h3.index_title a', text: 'An object')
    end
  end
end
