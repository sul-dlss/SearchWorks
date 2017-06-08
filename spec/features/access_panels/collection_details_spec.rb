require "spec_helper"

feature "Collection details access panel" do
  scenario "for collection objects" do
    visit catalog_path('29')


    within('.panel-collection-details') do
      expect(page).to have_css('.panel-heading', text: 'Collection details')
      within('.panel-body') do
        expect(page).to have_css('dt', text: 'Digital content')
        expect(page).to have_css('dd a', text: '1 item')
        expect(page).to have_css('dt', text: 'Finding aid')
        expect(page).to have_css('dd a', text: 'Online Archive of California')
        expect(page).to have_css('dt', text: 'Collection PURL')
        expect(page).to have_css('dd a', text: 'https://purl.stanford.edu/29')
      end
    end

  end
end
