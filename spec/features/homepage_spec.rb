# frozen_string_literal: true

require 'rails_helper'

feature 'Homepage' do
  before do
    visit quick_search_path
  end

  scenario 'has links to various search contexts' do
    within '.bento-panels' do
      expect(page).to have_css(
        'a[href="https://searchworks.stanford.edu"]',
        text: 'Catalog'
      )
      expect(page).to have_css(
        'a[href="https://searchworks.stanford.edu/articles"]',
        text: 'Articles+'
      )
      expect(page).to have_css(
        'a[href="https://guides.library.stanford.edu"]',
        text: 'Guides'
      )
      expect(page).to have_css(
        'a[href="https://library.stanford.edu"]',
        text: 'Library website'
      )
      expect(page).to have_css(
        'a[href="https://exhibits.stanford.edu"]',
        text: 'Exhibits'
      )
    end
  end
  scenario 'has links to more search tools' do
    expect(page).to have_css(
      'a[href="https://library.stanford.edu/search-services"]',
      text: 'More search tools'
    )
  end
end
