# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Facets Customizations" do
  scenario 'format is index sorted (not count)' do
    visit root_path

    book_index  = facet_index(facet_name: 'facet-format_hsim', value: 'Book')
    db_index    = facet_index(facet_name: 'facet-format_hsim', value: 'Database')
    image_index = facet_index(facet_name: 'facet-format_hsim', value: 'Image')

    expect(book_index).to be < db_index
    expect(db_index).to be < image_index
  end

  scenario 'mapping from the old format_main_ssim to the new format_hsim' do
    visit root_path(f: { format_main_ssim: ['Music recording'] })

    expect(page).to have_css '.document', count: 2
    expect(page).to have_css '.document .index_title', text: 'Best Album Every'
  end

  scenario 'library facet is index sorted (not count)' do
    visit root_path

    green_index = facet_index(facet_name: 'facet-library_code_facet_ssim', value: 'Green')
    music_index = facet_index(facet_name: 'facet-library_code_facet_ssim', value: 'Music')
    sdr_index   = facet_index(facet_name: 'facet-library_code_facet_ssim', value: 'Stanford Digital Repository')

    expect(green_index).to be < music_index
    expect(music_index).to be < sdr_index
  end

  scenario 'hiding other filters', :js do
    visit search_catalog_path(q: '', search_field: 'search')

    expect(page).to have_button 'Show all filters'
    expect(page).to have_no_button 'Language'

    click_button 'Show all filters'
    expect(page).to have_button 'Language'
  end

  scenario 'with an active facet in the other filters area', :js do
    visit search_catalog_path(q: '', search_field: 'search', f: { language: ['English'] })

    expect(page).to have_button 'Language'
    expect(page).to have_no_button 'Show all filters'
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

  scenario 'searching within a facet from the search results page', :js do
    visit root_path(q: '', search_field: 'search')

    click_button 'Show all filters'
    # click on the genre facet
    click_button 'Genre'

    expect(page).to have_no_link 'Video games'
    fill_in 'Search genre', with: 'Video'

    expect(page).to have_link 'Video games'

    click_link 'Video games'

    expect(page).to have_css '.constraint-value', text: 'Genre Video games'
  end
end
