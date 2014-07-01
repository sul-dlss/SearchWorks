require 'spec_helper'

feature "Top Navigation" do
  scenario "should have navigational links" do
    visit root_url
    within "#topnav" do
      within ".header-links" do
        expect(page).to have_css("a", text: "My Account")
        expect(page).to have_css("a", text: "Feedback")
      end
    end
  end
end
