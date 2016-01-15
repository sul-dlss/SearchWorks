require 'spec_helper'

feature "Top Navigation" do
  scenario "should have navigational links and top menu", js:true do
    visit root_path
    page.save_screenshot('tmp/screen.png')
    within "#topnav" do
      within ".header-links" do
        expect(page).to have_css("a", text: "My Account")
        expect(page).to have_css("a", text: "Feedback")
      end
      expect(page).to have_css("button.btn-topbar-menu.dropdown-toggle", visible:true)
      page.find('.btn-topbar-menu').click
      within ".sul-top-menu" do
        expect(page).to have_css("ul.dropdown-menu li a", text:"About", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Libraries", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Using the libraries", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Collections", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Research support", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Academic technology", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Ask us", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Connect from off campus", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Hours & locations", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Interlibrary borrowing", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Course guides", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Topic guides", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Suggest a purchase", visible:true)
      end
    end
  end
end
