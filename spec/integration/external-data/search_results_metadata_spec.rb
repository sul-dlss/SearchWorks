require "spec_helper"

describe "Search results metadata", :"data-integration" => true do
  describe "Uniform title" do
    it "should display for MARC records" do
      visit root_path
      fill_in 'q', with: '5645156'
      click_button 'search'

      within(first('.document')) do
        expect(page).to have_css('li', text: 'Johannes Brahms. English')
        expect(page).to have_css('li a', text: 'Johannes Brahms.')
      end
    end
  end

  describe "Author/Contributor" do
    it "should display for MARC records" do
      visit root_path
      fill_in 'q', with: '5645156'
      click_button 'search'

      within(first('.document')) do
        expect(page).to have_css('li a', text: 'Neunzig, Hans A.')
      end
    end
    it "should display for MODS records" do
      visit root_path
      fill_in 'q', with: 'cj765pw7168'
      click_button 'search'

      within(first('.document')) do
        expect(page).to have_css('li', text: 'Ghilion Beach, 107 Montgomery Street; Elliott Litho. Co., S. F. (lithographer)')
        expect(page).to have_css('li a', text: 'Ghilion Beach, 107 Montgomery Street; Elliott Litho. Co., S. F.')
      end
    end
  end

  describe "Imprint" do
    it "should display for MARC records" do
      visit root_path
      fill_in 'q', with: '7861312'
      click_button 'search'

      within(first('.document')) do
        expect(page).to have_css('li', text: 'Jackson : University Press of Mississippi, c2009.')
      end
    end
    it "should display for MODS records" do
      visit root_path
      fill_in 'q', with: 'cj765pw7168'
      click_button 'search'

      within(first('.document')) do
        expect(page).to have_css('li', text: 'circa 1900')
      end
    end
  end

  describe "Physical Description" do
    it "should display for MARC records" do
      visit root_path
      fill_in 'q', with: '7861312'
      click_button 'search'

      within(first('.document')) do
        expect(page).to have_css("dt", text: "Book")
        expect(page).to have_css("dd", text: "xiii, 161 p., [16] p. of plates : ill. ; 23 cm.")
      end
    end
  end

  describe "Collection" do
    it "should display for MARC records" do
      visit root_path
      fill_in 'q', with: '8836435'
      click_button 'search'

      within(first('.document')) do
        expect(page).to have_css("dt", text: "Collection")
        expect(page).to have_css("dd a", text: "The Caroline Batchelor Map Collection")
      end
    end
    it "should display for MODS records" do
      visit root_path
      fill_in 'q', with: 'gz624pt5394'
      click_button 'search'

      within(first('.document')) do
        expect(page).to have_css("dt", text: "Collection")
        expect(page).to have_css("dd a", text: "KZSU Project South interviews, 1965")
      end
    end
  end
end
