require "spec_helper"

feature "Collection details access panel" do
  scenario "for collection objects", js: true do
    visit solr_document_path('29')


    within('.panel-collection-details') do
      expect(page).to have_css('.panel-heading', text: 'Collection details')
      within('.panel-body') do
        expect(page).to have_css('dt', text: 'DIGITAL CONTENT')
        expect(page).to have_css('dd a', text: '1 item')
        expect(page).to have_css('dt', text: 'FINDING AID')
        expect(page).to have_css('dd a', text: 'Online Archive of California')
        expect(page).to have_css('dt', text: 'COLLECTION PURL')
        expect(page).to have_css('dd a', text: 'https://purl.stanford.edu/29')
      end
    end

  end
end
