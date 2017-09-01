require 'spec_helper'

describe 'Government Documents Access Point' do
  before do
    visit root_path

    within('.features') do
      click_link 'Government documents'
    end
  end

  it 'provides a masthead in search results' do
    within('.government-documents-masthead') do
      expect(page).to have_css('h1', text: 'Government documents')
    end
  end

  it 'takes the user to the govdocs url' do
    expect(current_url).to eq govdocs_url
  end

  it 'returns the govenment document results' do
    within('.constraint') do
      expect(page).to have_css('.filterName', text: 'Genre')
      expect(page).to have_css('.filterValue', text: 'Government document')
    end

    expect(total_results).to eq 2
  end
end
