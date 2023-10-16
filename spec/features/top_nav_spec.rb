require 'rails_helper'

RSpec.feature "Top Navigation" do
  scenario "should have navigational links and top menu", :js do
    visit root_path
    within "#topnav" do
      within ".header-links" do
        expect(page).to have_css("a", text: "Login")
        expect(page).to have_css("a", text: "My Account")
        expect(page).to have_css("a", text: "Feedback")
      end
    end
  end
end
