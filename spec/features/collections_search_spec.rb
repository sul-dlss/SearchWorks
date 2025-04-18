# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Searching within collections" do
  it "returns the zero results page when no items are present" do
    visit search_catalog_path(f: { collection: ['29'] })

    fill_in 'q', with: 'abcde'
    click_button 'search'

    expect(page).to have_css('h1', text: 'No results found')
  end
end
