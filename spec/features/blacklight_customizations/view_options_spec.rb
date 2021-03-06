require "spec_helper"

feature "View options" do
  scenario "should include our custom options" do
    visit root_path
    fill_in 'q', with: ''
    click_button 'search'

    within('#view-type-dropdown') do
      expect(page).to have_css("li a.view-type-list span.view-type-label", text: 'Normal')
      expect(page).to have_css("li a.view-type-list i.fa.fa-th-list")

      expect(page).to have_css("li a.view-type-gallery span.view-type-label", text: 'Gallery')
      expect(page).to have_css("li a.view-type-gallery i.fa.fa-th")

      expect(page).to have_css("li a.view-type-brief span.view-type-label", text: 'Brief')
      expect(page).to have_css("li a.view-type-brief i.fa.fa-align-justify")
    end
  end
end
