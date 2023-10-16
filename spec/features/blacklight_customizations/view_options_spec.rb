require 'rails_helper'

RSpec.feature "View options" do
  scenario "includes our custom options" do
    visit root_path
    fill_in 'q', with: ''
    click_button 'search'

    within '#view-type-dropdown' do
      expect(page).to have_css("a.view-type-list span.view-type-label", text: 'normal')
      expect(page).to have_css("a.view-type-list i.fa.fa-th-list")

      expect(page).to have_css("a.view-type-gallery span.view-type-label", text: 'gallery')
      expect(page).to have_css("a.view-type-gallery i.fa.fa-th")

      expect(page).to have_css("a.view-type-brief span.view-type-label", text: 'brief')
      expect(page).to have_css("a.view-type-brief i.fa.fa-align-justify")
    end
  end
end
