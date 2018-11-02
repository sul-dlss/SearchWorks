require "spec_helper"

describe "Breadcrumb Customizations", type: :feature do
  describe "for collections" do
    it "should display the title of the collection and not the ID" do
      stub_article_service(docs: [])
      visit search_catalog_path(f: { collection: ['29'] })

      within('.breadcrumb') do
        expect(page).to have_css('.filterValue', text: 'Image Collection1')
        expect(page).to_not have_content('29')
      end
    end
  end
end
