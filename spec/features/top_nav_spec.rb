# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Top Navigation" do
  scenario "should have navigational links and top menu", :js do
    visit root_path
    within "#topnav .header-links" do
      expect(page).to have_link "Login"
      expect(page).to have_link "My Account"
      expect(page).to have_link "Feedback"
    end
  end
end
