require "spec_helper"

describe 'Request Links', type: :feature, :"data-integration" => true do
  describe 'Location level request links' do
    it 'should be rendered for configured -30 locations' do
      visit catalog_path '4085340'

      within('ul.location') do
        expect(page).to have_css('li', text: /University Archives\s*Request/)
        expect(page).to have_css('li a', text: "Request")
      end
    end
    describe 'Hopkins' do
      it 'should not render request links for items that exist at other libraries' do
        visit catalog_path("10180544")

        within(first("ul.location")) do
          expect(page).to_not have_css('li a', text: "Request")
        end
      end
      it 'should not render request links for items that are available online' do
        visit catalog_path("10402123")

        expect(page).to_not have_css('li a', text: "Request")
      end
      it 'should render request links for items that are not available online or at other libraries' do
        visit catalog_path("3010807")

        expect(page).to have_css('li a', text: "Request")
      end
    end
  end
end