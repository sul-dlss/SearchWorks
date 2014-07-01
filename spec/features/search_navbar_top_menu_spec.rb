require 'spec_helper'

feature "Search NavBar Top Menu" do
  before do
    visit root_url
  end

  scenario "should have top menu visible" do
    within "#search-navbar" do
      within "div.navbar-header" do
        expect(page).to have_css("button.dropdown-toggle", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Stanford University Libraries", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"About", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Libraries", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Using the libraries", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Collections", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Research support", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Academic technology", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Ask us", visible:true)
        expect(page).to have_css("ul.dropdown-menu li", text:"Quick links", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Connect from off campus", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Hours & locations", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Interlibrary borrowing", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Print, copy, scan", visible:true)
        expect(page).to have_css("ul.dropdown-menu li a", text:"Topic guides", visible:true)
      end
    end
  end

end
