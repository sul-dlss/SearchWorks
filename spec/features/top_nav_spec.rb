require 'spec_helper'

feature "Top Navigation" do
  scenario "should have navigational links" do
    visit root_url
    within "#topnav" do
      within "ul.navbar-nav" do
        expect(page).to have_css("li a", text: "My Account")
        expect(page).to have_css("li.disabled a", text: "Feedback")
      end
    end
  end
end