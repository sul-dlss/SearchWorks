# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Digital Collections Search" do
  before do
    visit root_path
    within '.features' do
      click_link "Digital collections"
    end
  end

  scenario "should have the filter applied" do
    within(".breadcrumb") do
      expect(page).to have_css('.filter-name', text: "Collection type")
      expect(page).to have_css('.filter-value', text: "Digital Collection")
    end
  end
  scenario "should return results" do
    expect(page).to have_css("#documents .document")
  end
end
