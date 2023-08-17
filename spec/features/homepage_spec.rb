# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Homepage' do
  before do
    visit quick_search_path
  end

  scenario 'has links to various search contexts' do
    within '.bento-panels' do
      expect(page).to have_link 'Catalog', href: 'https://searchworks.stanford.edu'
      expect(page).to have_link 'Articles+', href: 'https://searchworks.stanford.edu/articles'
      expect(page).to have_link 'Guides', href: 'https://guides.library.stanford.edu'
      expect(page).to have_link 'Library website', href: 'https://library.stanford.edu'
      expect(page).to have_link 'Exhibits', href: 'https://exhibits.stanford.edu'
    end

    expect(page).to have_link 'More search tools', href: 'https://guides.library.stanford.edu/search-services'
  end
end
