require "spec_helper"

describe 'Request Links', type: :feature, :"data-integration" => true do
  describe 'Location level request links' do
    it 'should be rendered for configured -30 locations' do
      visit solr_document_path '4085340'

      within('.location') do
        expect(page).to have_css('.location-name', text: "University Archives")
        expect(page).to have_css('.request-button', text: "Request on-site access")
      end
    end
    describe 'Hopkins' do
      it 'should not render request links for items that exist at other libraries' do
        visit solr_document_path("10180544")

        within(first(".location")) do
          expect(page).not_to have_css('.request-button', text: "Request on-site access")
        end
      end
      it 'should not render request links for items that are available online' do
        visit solr_document_path("10402123")

        expect(page).to_not have_css('.request-button', text: "Request on-site access")
      end
      it 'should render request links for items that are not available online or at other libraries' do
        visit solr_document_path("3010807")

        expect(page).to have_css('.request-button', text: "Request")
      end
    end
  end
end
