require 'rails_helper'

RSpec.describe "Breadcrumb Customizations" do
  describe "for collections" do
    it "displays the title of the collection and not the ID" do
      visit search_catalog_path(f: { collection: ['29'] })

      within('.breadcrumb') do
        expect(page).to have_css('.filter-value', text: 'Image Collection1')
        expect(page).to have_no_content('29')
      end
    end
  end
end
