# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Facets Customizations" do
  scenario 'resource type is index sorted (not count)' do
    visit root_path

    book_index  = facet_index(facet_name: 'facet-format_main_ssim', value: 'Book')
    db_index    = facet_index(facet_name: 'facet-format_main_ssim', value: 'Database')
    image_index = facet_index(facet_name: 'facet-format_main_ssim', value: 'Image')

    expect(book_index).to be < db_index
    expect(db_index).to be < image_index
  end

  scenario 'library facet is index sorted (not count)' do
    visit root_path

    green_index = facet_index(facet_name: 'facet-building_facet', value: 'Green')
    music_index = facet_index(facet_name: 'facet-building_facet', value: 'Music')
    sdr_index   = facet_index(facet_name: 'facet-building_facet', value: 'Stanford Digital Repository')

    expect(green_index).to be < music_index
    expect(music_index).to be < sdr_index
  end

  scenario 'searching within a facet', :js do
    visit facet_catalog_path('genre_ssim')

    aggregate_failures do
      expect(page).to have_css '.modal-body .input-group'

      # we've added an icon and hidden the label text
      within '.modal-body .input-group' do
        expect(page).to have_css '.bi-search'
        expect(page).to have_css 'input[type="text"][placeholder="Search genre"]'
      end
    end

    fill_in 'Search genre', with: 'The'

    # it does a search, and uses a facet.method that supports searching
    aggregate_failures do
      expect(page).to have_text 'Thesis/Dissertation'
      expect(page).to have_no_text 'Art music'
    end
  end
end
