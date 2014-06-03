require "spec_helper"

describe "Mods Subjects", feature: true, :"data-integration" => true do
  describe "linking" do
    
    it "should do a subject terms search" do
      visit catalog_path('vb267mw8946')

      expect(page).to have_css('a', text: 'Addison, Joseph, 1672-1719')
      click_link 'Addison, Joseph, 1672-1719'

      within('.breadcrumb') do
        expect(page).to have_css('.filterName', text: 'Subject terms')
        expect(page).to have_css('.filterValue', text: '"Addison, Joseph, 1672-1719"')
      end
      within('.page_links') do
        expect(page).to have_css('.page_entries', text: /^1 - 10 of \d{3}$/)
      end
      expect(page).to have_css('.index_title', text: 'Joseph Addison as literary critic')
    end
  end
end
