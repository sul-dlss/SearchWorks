require "spec_helper"
#6780453

describe "Merged Image Collection", feature: true, :"data-integration" => true do
  describe "search results" do
    before do
      visit root_path
      fill_in 'q', with: '6780453'
      click_button 'search'
    end
    it "should render metadata and a filmstrip" do
      skip("Needs item-level-merge in external data integration index")
      expect(page).to have_css('h5 a', text: "Reid W. Dennis collection of California lithographs, 1850-1906")
      expect(page).to have_css('dt', text: "Digital content")
      expect(page).to have_css('dd', text: "48 items")

      within('.image-filmstrip') do
        within('ul.listing') do
          expect(page).to have_css("a img.thumb-zz400gd3785")
          expect(page).to have_css("a img.thumb-pd337xr9038")
        end
      end
    end
  end
  describe "record view" do
    before do
      visit catalog_path('6780453')
    end
    it "should render metadata and a filmstrip" do
      skip("Needs item-level-merge in external data integration index")
      expect(page).to have_css('h1', text: "Reid W. Dennis collection of California lithographs, 1850-1906")

      expect(page).to have_css('h2', text: "Contents/Summary")
      expect(page).to have_css('h2', text: "Subjects")
      expect(page).to have_css('h2', text: "Bibliographic information")

      within('.image-filmstrip') do
        within('ul.listing') do
          expect(page).to have_css("a img.thumb-zz400gd3785")
          expect(page).to have_css("a img.thumb-pd337xr9038")
        end
      end
    end
  end
end
