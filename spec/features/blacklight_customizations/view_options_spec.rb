require "spec_helper"

feature "View options" do
  scenario "should include our custom options" do
    visit root_path
    fill_in 'q', with: ''
    click_button 'search'

    # first is displayed only on desktop layout
    within all('#view-type-dropdown')[0] do
      expect(page).to have_css("li a.view-type-list span.view-type-label", text: 'normal')
      expect(page).to have_css("li a.view-type-list i.fa.fa-th-list")

      expect(page).to have_css("li a.view-type-gallery span.view-type-label", text: 'gallery')
      expect(page).to have_css("li a.view-type-gallery i.fa.fa-th")

      expect(page).to have_css("li a.view-type-brief span.view-type-label", text: 'brief')
      expect(page).to have_css("li a.view-type-brief i.fa.fa-align-justify")
    end

    # second is displayed only on mobile layout
    within all('#view-type-dropdown')[1] do
      expect(page).to have_css("li a.view-type-list span.view-type-label", text: 'normal')
      expect(page).to have_css("li a.view-type-list i.fa.fa-th-list")

      expect(page).to have_css("li a.view-type-gallery span.view-type-label", text: 'gallery')
      expect(page).to have_css("li a.view-type-gallery i.fa.fa-th")

      expect(page).to have_css("li a.view-type-brief span.view-type-label", text: 'brief')
      expect(page).to have_css("li a.view-type-brief i.fa.fa-align-justify")
    end
  end
end
