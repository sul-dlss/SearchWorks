# frozen_string_literal: true

require 'rails_helper'

feature 'Homepage' do
  before do
    visit quick_search_path
  end
  scenario 'has links to various search contexts' do
    within '.homepage-panels' do
      expect(page).to have_css(
        'a[href="https://searchworks.stanford.edu"]',
        text: 'Catalog'
      )
      expect(page).to have_css(
        'a[href="https://searchworks.stanford.edu/articles"]',
        text: 'Articles+'
      )
      expect(page).to have_css(
        'a[href="https://library.stanford.edu"]',
        text: 'Library website'
      )
      expect(page).to have_css(
        'a[href="https://yewno.com/edu"]',
        text: 'Yewno'
      )
    end
  end
end
