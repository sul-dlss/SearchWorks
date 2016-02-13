require "spec_helper"

describe "Breadcrumb Customizations", type: :feature do
  describe "for collections" do
    it "should display the title of the collection and not the ID" do
      visit root_path
      fill_in 'q', with: '29'
      click_button 'search'

      find('a.label-items-online', text: 'View this item').click

      within('.breadcrumb') do
        expect(page).to have_css('.filterValue', text: 'Image Collection1')
        expect(page).to_not have_content('29')
      end
    end
  end
end
