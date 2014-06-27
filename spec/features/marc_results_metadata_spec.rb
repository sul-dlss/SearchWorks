require "spec_helper"

describe "MARC Metadata in search results" do
  describe "uniform title" do
    before do
      visit root_path
      fill_in 'q', with: '18'
      click_button 'search'
    end
    it "should link the uniform title" do
      within(first('.document')) do
        within('ul.document-metadata') do
          expect(page).to have_css('li', text: 'Instrumental music. Selections')
          expect(page).to have_css('li a', text: 'Instrumental music.')
        end
      end
    end
  end
end
