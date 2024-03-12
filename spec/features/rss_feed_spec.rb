# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RSS Feeds' do
  before do
    visit root_path
    click_button 'search'
  end

  it 'provides a link to the new books feed in search results' do
    within('.search_num_of_results') do
      expect(page).to have_css('a i.rss-icon')
    end
  end

  it 'sorts the new books feed by the date_cataloged field' do
    within('.search_num_of_results') do
      click_link 'RSS feed for this result'
    end

    ids = all(:xpath, '//entry/id')
    expect(ids[0].text).to match(%r{/view/46$})
    expect(ids[1].text).to match(%r{/view/44$})
  end
end
