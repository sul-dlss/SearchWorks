require "spec_helper"

describe "Breadcrumb", type: :feature, :"data-integration" => true do
  describe "for collections" do
    it "should display the title of the collection and not the ID" do
      visit catalog_path('6780453')

      click_link '48 items online'

      within('.breadcrumb') do
        expect(page).to have_css('.filterValue', text: 'The Reid W. Dennis Collection of California Lithographs')
        expect(page).to_not have_content('6780453')
      end
    end
  end
end
