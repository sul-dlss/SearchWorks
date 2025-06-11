# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Homepage', :js do
  before do
    visit search_path
  end

  scenario 'has text for top level headings and sections for search tools and other sources' do
    aggregate_failures do
      # High leavel headings
      expect(page).to have_text 'Stanford University Libraries\' search tools'
      expect(page).to have_text 'Other sources searched'

      # First two search tools sections
      expect(page).to have_text 'SearchWorks Catalog'
      expect(page).to have_text 'SearchWorks Articles+'

      # First two
      expect(page).to have_text 'Library website'
      expect(page).to have_text 'Guides'
    end

    expect(page).to be_accessible
  end
end
