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

  scenario "while not in an access point facet title does not change", :js do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'

    within "div#facets" do
      expect(page).to have_css("h2.facets-heading", text: "Filters")
    end
  end
end
