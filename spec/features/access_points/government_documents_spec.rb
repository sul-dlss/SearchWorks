# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Government Documents Access Point' do
  before do
    visit root_path

    within('.features') do
      click_link 'Government documents'
    end
  end

  it 'provides a masthead in search results' do
    expect(page).to have_css('h1', text: 'Government documents')
  end

  it 'takes the user to the govdocs url' do
    expect(current_url).to eq govdocs_url
  end

  it 'returns the govenment document results' do
    within('.constraint') do
      expect(page).to have_css('.filter-name', text: 'Genre')
      expect(page).to have_css('.filter-value', text: 'Government document')
    end

    expect(page).to have_text '1 - 12 of 12'
  end
end
