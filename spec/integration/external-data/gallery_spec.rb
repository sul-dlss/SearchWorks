require "spec_helper"

describe "Gallery View", feature: true, :"data-integration" => true  do
  describe 'Callnumber/Library Bar' do
    it 'should display the first call number and a single library name if a record only exists at one library' do
      visit search_catalog_path(view: 'gallery', q: '7861312')
      within('.callnumber-bar') do
        expect(page).to have_content("F345.3 .R44 M38 2009")
        expect(page).to have_content("Green Library")
      end
    end
    it 'should display the first call number and the number of libraries if a record exists in many libraries' do
      visit search_catalog_path(view: 'gallery', q: '10436425')
      within('.callnumber-bar') do
        expect(page).to have_content("N7399 .N53 J4433 2014")
        expect(page).to have_content("in 2 libraries")
      end
    end
    it 'should display "Stanford Digital Repository" for MODS records w/o holdings' do
      visit search_catalog_path(view: 'gallery', q: 'nz353cp1092')
      within('.callnumber-bar') do
        expect(page).to have_content("Stanford Digital Repository")
      end
    end
  end
end