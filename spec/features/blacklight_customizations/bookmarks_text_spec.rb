# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Bookmarks Select/UnSelect Text", :js do
  before do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'
  end

  scenario "has bookmarks text as select" do
    within first("div.documentHeader") do
      within "label.toggle-bookmark-label" do
        expect(page).to have_css("span", text: "Select")
      end
    end
  end

  scenario "has bookmarks text as selected" do
    within first("div.documentHeader") do
      find('.blacklight-icons-bookmark').click
    end
    within first("div.documentHeader") do
      expect(page).to have_css("span", text: "Selected", visible: true)
    end
  end
end
